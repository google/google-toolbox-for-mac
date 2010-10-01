//
//  GTMServiceManagement.c
//
//  Copyright 2010 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

// Note: launch_data_t have different ownership semantics than CFType/NSObjects.
//       In general if you create one, you are responsible for releasing it.
//       However, if you add it to a collection (LAUNCH_DATA_DICTIONARY,
//       LAUNCH_DATA_ARRAY), you no longer own it, and are no longer
//       responsible for releasing it (you may be responsible for the array
//       or dictionary of course). A corrollary of this is that a
//       launch_data_t can only be in one collection at any given time.

#include "GTMServiceManagement.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4

typedef struct {
  CFMutableDictionaryRef dict;
  bool convert_non_standard_objects;
  CFErrorRef *error;
} GTMLToCFDictContext;

typedef struct {
  launch_data_t dict;
  CFErrorRef *error;
} GTMCFToLDictContext;

static CFErrorRef GTMCFLaunchCreateUnlocalizedError(CFIndex code,
                                                    CFStringRef format, ...) CF_FORMAT_FUNCTION(2, 3);

static CFErrorRef GTMCFLaunchCreateUnlocalizedError(CFIndex code,
                                                    CFStringRef format, ...) {
  CFDictionaryRef user_info = NULL;
  if (format) {
    va_list args;
    va_start(args, format);
    CFStringRef string
      = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault,
                                             NULL,
                                             format,
                                             args);
    user_info = CFDictionaryCreate(kCFAllocatorDefault,
                                   (const void **)&kCFErrorDescriptionKey,
                                   (const void **)&string,
                                   1,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   &kCFTypeDictionaryValueCallBacks);
    CFRelease(string);
    va_end(args);
  }
  CFErrorRef error = CFErrorCreate(kCFAllocatorDefault,
                                   kCFErrorDomainPOSIX,
                                   code,
                                   user_info);
  if (user_info) {
    CFRelease(user_info);
  }
  return error;
}

static void GTMConvertCFDictEntryToLaunchDataDictEntry(const void *key,
                                                       const void *value,
                                                       void *context) {
  GTMCFToLDictContext *local_context = (GTMCFToLDictContext *)context;
  if (*(local_context->error)) return;

  launch_data_t launch_value
    = GTMLaunchDataCreateFromCFType(value, local_context->error);
  if (launch_value) {
    launch_data_t launch_key
      = GTMLaunchDataCreateFromCFType(key, local_context->error);
    if (launch_key) {
      bool goodInsert
        = launch_data_dict_insert(local_context->dict,
                                  launch_value,
                                  launch_data_get_string(launch_key));
      if (!goodInsert) {
        *(local_context->error)
          = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                              CFSTR("launch_data_dict_insert "
                                                    "failed key: %@ value: %@"),
                                              key,
                                              value);
        launch_data_free(launch_value);
      }
      launch_data_free(launch_key);
    }
  }
}

static void GTMConvertLaunchDataDictEntryToCFDictEntry(const launch_data_t value,
                                                       const char *key,
                                                       void *context) {
  GTMLToCFDictContext *local_context = (GTMLToCFDictContext *)context;
  if (*(local_context->error)) return;

  CFTypeRef cf_value
    = GTMCFTypeCreateFromLaunchData(value,
                                    local_context->convert_non_standard_objects,
                                    local_context->error);
  if (cf_value) {
    CFStringRef cf_key = CFStringCreateWithCString(kCFAllocatorDefault,
                                                   key,
                                                   kCFStringEncodingUTF8);
    if (cf_key) {
      CFDictionarySetValue(local_context->dict, cf_key, cf_value);
      CFRelease(cf_key);
    } else {
      *(local_context->error)
        = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                            CFSTR("Unable to create key %s"),
                                            key);
    }
    CFRelease(cf_value);
  }
}

static launch_data_t GTMPerformOnLabel(const char *verb,
                                       CFStringRef jobLabel,
                                       CFErrorRef *error) {
  launch_data_t resp = NULL;
  launch_data_t label = GTMLaunchDataCreateFromCFType(jobLabel, error);
  if (*error == NULL) {
    launch_data_t msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
    launch_data_dict_insert(msg, label, verb);
    resp = launch_msg(msg);
    launch_data_free(msg);
    if (!resp) {
      *error = GTMCFLaunchCreateUnlocalizedError(errno, CFSTR(""));
    }
  }
  return resp;
}

launch_data_t GTMLaunchDataCreateFromCFType(CFTypeRef cf_type_ref,
                                            CFErrorRef *error) {
  launch_data_t result = NULL;
  CFErrorRef local_error = NULL;
  if (cf_type_ref == NULL) {
    local_error = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                                    CFSTR("NULL CFType"));
    goto exit;
  }

  CFTypeID cf_type = CFGetTypeID(cf_type_ref);
  if (cf_type == CFStringGetTypeID()) {
    CFIndex length = CFStringGetLength(cf_type_ref);
    CFIndex max_length
      = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
    char *buffer = calloc(max_length, sizeof(char));
    size_t buffer_size = max_length * sizeof(char);
    if (buffer) {
      if (CFStringGetCString(cf_type_ref,
                             buffer,
                             buffer_size,
                             kCFStringEncodingUTF8)) {
        result = launch_data_alloc(LAUNCH_DATA_STRING);
        launch_data_set_string(result, buffer);
      } else {
        local_error
          = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                              CFSTR("CFStringGetCString failed %@"),
                                              cf_type_ref);
      }
      free(buffer);
    } else {
      local_error = GTMCFLaunchCreateUnlocalizedError(ENOMEM,
                                                      CFSTR("calloc of %zu failed"),
                                                      buffer_size);
    }
  } else if (cf_type == CFBooleanGetTypeID()) {
    result = launch_data_alloc(LAUNCH_DATA_BOOL);
    launch_data_set_bool(result, CFBooleanGetValue(cf_type_ref));
  } else if (cf_type == CFArrayGetTypeID()) {
    CFIndex count = CFArrayGetCount(cf_type_ref);
    result = launch_data_alloc(LAUNCH_DATA_ARRAY);
    for (CFIndex i = 0; i < count; i++) {
      CFTypeRef array_value = CFArrayGetValueAtIndex(cf_type_ref, i);
      if (array_value) {
        launch_data_t launch_value
          = GTMLaunchDataCreateFromCFType(array_value, &local_error);
        if (local_error) break;
        launch_data_array_set_index(result, launch_value, i);
      }
    }
  } else if (cf_type == CFDictionaryGetTypeID()) {
    result = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
    GTMCFToLDictContext context = { result, &local_error };
    CFDictionaryApplyFunction(cf_type_ref,
                              GTMConvertCFDictEntryToLaunchDataDictEntry,
                              &context);
  } else if (cf_type == CFDataGetTypeID()) {
    result = launch_data_alloc(LAUNCH_DATA_OPAQUE);
    launch_data_set_opaque(result,
                           CFDataGetBytePtr(cf_type_ref),
                           CFDataGetLength(cf_type_ref));
  } else if (cf_type == CFNumberGetTypeID()) {
    CFNumberType cf_number_type = CFNumberGetType(cf_type_ref);
    switch (cf_number_type) {
      case kCFNumberSInt8Type:
      case kCFNumberSInt16Type:
      case kCFNumberSInt32Type:
      case kCFNumberSInt64Type:
      case kCFNumberCharType:
      case kCFNumberShortType:
      case kCFNumberIntType:
      case kCFNumberLongType:
      case kCFNumberLongLongType:
      case kCFNumberCFIndexType:
      case kCFNumberNSIntegerType:{
        long long value;
        if (CFNumberGetValue(cf_type_ref, kCFNumberLongLongType, &value)) {
          result = launch_data_alloc(LAUNCH_DATA_INTEGER);
          launch_data_set_integer(result, value);
        } else {
          local_error
            = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                                CFSTR("Unknown to convert: %@"),
                                                cf_type_ref);
        }
        break;
      }

      case kCFNumberFloat32Type:
      case kCFNumberFloat64Type:
      case kCFNumberFloatType:
      case kCFNumberDoubleType:
      case kCFNumberCGFloatType: {
        double value;
        if (CFNumberGetValue(cf_type_ref, kCFNumberDoubleType, &value)) {
          result = launch_data_alloc(LAUNCH_DATA_REAL);
          launch_data_set_real(result, value);
        } else {
          local_error
            = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                                CFSTR("Unknown to convert: %@"),
                                                cf_type_ref);
        }
        break;
      }

      default:
        local_error
          = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                              CFSTR("Unknown CFNumberType %lld"),
                                              (long long)cf_number_type);
        break;
    }
  } else {
    local_error
      = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                          CFSTR("Unknown CFTypeID %lu"),
                                          cf_type);
  }

exit:
  if (error) {
    *error = local_error;
  } else if (local_error) {
    CFShow(local_error);
    CFRelease(local_error);
  }
  return result;
}

CFTypeRef GTMCFTypeCreateFromLaunchData(launch_data_t ldata,
                                        bool convert_non_standard_objects,
                                        CFErrorRef *error) {
  CFTypeRef cf_type_ref = NULL;
  CFErrorRef local_error = NULL;
  if (ldata == NULL) {
    local_error = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                                    CFSTR("NULL ldata"));
    goto exit;
  }

  launch_data_type_t ldata_type = launch_data_get_type(ldata);
  switch (ldata_type) {
    case LAUNCH_DATA_STRING:
      cf_type_ref
        = CFStringCreateWithCString(kCFAllocatorDefault,
                                    launch_data_get_string(ldata),
                                    kCFStringEncodingUTF8);
      break;

    case LAUNCH_DATA_INTEGER: {
      long long value = launch_data_get_integer(ldata);
      cf_type_ref = CFNumberCreate(kCFAllocatorDefault,
                                   kCFNumberLongLongType,
                                   &value);
      break;
    }

    case LAUNCH_DATA_REAL: {
      double value = launch_data_get_real(ldata);
      cf_type_ref = CFNumberCreate(kCFAllocatorDefault,
                                   kCFNumberDoubleType,
                                   &value);
      break;
    }

    case LAUNCH_DATA_BOOL: {
      bool value = launch_data_get_bool(ldata);
      cf_type_ref = value ? kCFBooleanTrue : kCFBooleanFalse;
      CFRetain(cf_type_ref);
      break;
    }

    case LAUNCH_DATA_OPAQUE: {
      size_t size = launch_data_get_opaque_size(ldata);
      void *data = launch_data_get_opaque(ldata);
      cf_type_ref = CFDataCreate(kCFAllocatorDefault, data, size);
      break;
    }

    case LAUNCH_DATA_ARRAY: {
      size_t count = launch_data_array_get_count(ldata);
      cf_type_ref = CFArrayCreateMutable(kCFAllocatorDefault,
                                         count,
                                         &kCFTypeArrayCallBacks);
      if (cf_type_ref) {
        for (size_t i = 0; !local_error && i < count; i++) {
          launch_data_t l_sub_data = launch_data_array_get_index(ldata, i);
          CFTypeRef cf_sub_type
            = GTMCFTypeCreateFromLaunchData(l_sub_data,
                                            convert_non_standard_objects,
                                            &local_error);
          if (cf_sub_type) {
            CFArrayAppendValue((CFMutableArrayRef)cf_type_ref, cf_sub_type);
            CFRelease(cf_sub_type);
          }
        }
      }
      break;
    }

    case LAUNCH_DATA_DICTIONARY:
      cf_type_ref = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                              0,
                                              &kCFTypeDictionaryKeyCallBacks,
                                              &kCFTypeDictionaryValueCallBacks);
      if (cf_type_ref) {
        GTMLToCFDictContext context = {
          (CFMutableDictionaryRef)cf_type_ref,
          convert_non_standard_objects,
          &local_error
        };
        launch_data_dict_iterate(ldata,
                                 GTMConvertLaunchDataDictEntryToCFDictEntry,
                                 &context);
      }
      break;

    case LAUNCH_DATA_FD:
      if (convert_non_standard_objects) {
        int file_descriptor = launch_data_get_fd(ldata);
        cf_type_ref = CFNumberCreate(kCFAllocatorDefault,
                                     kCFNumberIntType,
                                     &file_descriptor);
      }
      break;

    case LAUNCH_DATA_MACHPORT:
      if (convert_non_standard_objects) {
        mach_port_t port = launch_data_get_machport(ldata);
        cf_type_ref = CFNumberCreate(kCFAllocatorDefault,
                                     kCFNumberIntType,
                                     &port);
      }
      break;

    default:
      local_error =
        GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                          CFSTR("Unknown launchd type %d"),
                                          ldata_type);
      break;
  }
exit:
  if (error) {
    *error = local_error;
  } else if (local_error) {
    CFShow(local_error);
    CFRelease(local_error);
  }
  return cf_type_ref;
}

Boolean GTMSMJobSubmit(CFDictionaryRef cf_job, CFErrorRef *error) {
  CFErrorRef local_error = NULL;
  launch_data_t launch_job = GTMLaunchDataCreateFromCFType(cf_job,
                                                           &local_error);
  if (!local_error) {
    launch_data_t jobs = launch_data_alloc(LAUNCH_DATA_ARRAY);
    launch_data_array_set_index(jobs, launch_job, 0);
    launch_data_t msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
    launch_data_dict_insert(msg, jobs, LAUNCH_KEY_SUBMITJOB);
    launch_data_t resp = launch_msg(msg);
    if (resp) {
      launch_data_type_t resp_type = launch_data_get_type(resp);
      switch (resp_type) {
        case LAUNCH_DATA_ARRAY:
          for (size_t i = 0; i < launch_data_array_get_count(jobs); i++) {
            launch_data_t job_response = launch_data_array_get_index(resp, i);
            launch_data_t job = launch_data_array_get_index(jobs, i);
            launch_data_t job_label
              = launch_data_dict_lookup(job, LAUNCH_JOBKEY_LABEL);
            const char *job_string
              = job_label ? launch_data_get_string(job_label) : "Unlabeled job";
            if (LAUNCH_DATA_ERRNO == launch_data_get_type(job_response)) {
              int job_err = launch_data_get_errno(job_response);
              if (job_err != 0) {
                // We only keep the last error
                if (local_error) {
                  CFRelease(local_error);
                  local_error = NULL;
                }
                switch (job_err) {
                  case EEXIST:
                    local_error
                      = GTMCFLaunchCreateUnlocalizedError(job_err,
                                                          CFSTR("%s already loaded"),
                                                          job_string);
                    break;
                  case ESRCH:
                    local_error
                      = GTMCFLaunchCreateUnlocalizedError(job_err,
                                                          CFSTR("%s not loaded"),
                                                          job_string);
                    break;
                  default:
                    local_error
                      = GTMCFLaunchCreateUnlocalizedError(job_err,
                                                          CFSTR("%s failed to load"),
                                                          job_string);
                    break;
                }
              }
            }
          }
          break;

        case LAUNCH_DATA_ERRNO: {
          int e = launch_data_get_errno(resp);
          if (e) {
            local_error = GTMCFLaunchCreateUnlocalizedError(e, CFSTR(""));
          }
          break;
        }

        default:
          local_error
            = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                                CFSTR("unknown response from launchd %d"),
                                                resp_type);
          break;
      }
      launch_data_free(resp);
      launch_data_free(msg);
    } else {
      local_error = GTMCFLaunchCreateUnlocalizedError(errno, CFSTR(""));
    }

  }
  if (error) {
    *error = local_error;
  } else if (local_error) {
    CFShow(local_error);
    CFRelease(local_error);
  }
  return local_error == NULL;
}

CFDictionaryRef GTMSMJobCheckIn(CFErrorRef *error) {
  CFErrorRef local_error = NULL;
  CFDictionaryRef check_in_dict = NULL;
  launch_data_t msg = launch_data_new_string(LAUNCH_KEY_CHECKIN);
  launch_data_t resp = launch_msg(msg);
  launch_data_free(msg);
  if (resp) {
    launch_data_type_t resp_type = launch_data_get_type(resp);
    switch (resp_type) {
      case LAUNCH_DATA_DICTIONARY:
        check_in_dict = GTMCFTypeCreateFromLaunchData(resp, true, &local_error);
        break;

      case LAUNCH_DATA_ERRNO: {
        int e = launch_data_get_errno(resp);
        if (e) {
          local_error = GTMCFLaunchCreateUnlocalizedError(e, CFSTR(""));
        }
        break;
      }

      default:
        local_error
          = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                              CFSTR("unknown response from launchd %d"),
                                              resp_type);
        break;
    }
    launch_data_free(resp);
  } else {
    local_error = GTMCFLaunchCreateUnlocalizedError(errno, CFSTR(""));
  }
  if (error) {
    *error = local_error;
  } else if (local_error) {
    CFShow(local_error);
    CFRelease(local_error);
  }
  return check_in_dict;
}

Boolean GTMSMJobRemove(CFStringRef jobLabel, CFErrorRef *error) {
  CFErrorRef local_error = NULL;
  launch_data_t resp = GTMPerformOnLabel(LAUNCH_KEY_REMOVEJOB,
                                         jobLabel,
                                         &local_error);
  if (resp) {
    launch_data_type_t resp_type = launch_data_get_type(resp);
    switch (resp_type) {
      case LAUNCH_DATA_ERRNO: {
        int e = launch_data_get_errno(resp);
        if (e) {
          local_error = GTMCFLaunchCreateUnlocalizedError(e, CFSTR(""));
        }
        break;
      }

      default:
        local_error
          = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                              CFSTR("unknown response from launchd %d"),
                                              resp_type);
        break;
    }
    launch_data_free(resp);
  } else {
    local_error = GTMCFLaunchCreateUnlocalizedError(errno, CFSTR(""));
  }
  if (error) {
    *error = local_error;
  } else if (local_error) {
    CFShow(local_error);
    CFRelease(local_error);
  }
  return local_error == NULL;
}

CFDictionaryRef GTMSMJobCopyDictionary(CFStringRef jobLabel) {
  CFDictionaryRef dict = NULL;
  CFErrorRef error = NULL;
  launch_data_t resp = GTMPerformOnLabel(LAUNCH_KEY_GETJOB,
                                         jobLabel,
                                         &error);
  if (resp) {
    launch_data_type_t ldata_Type = launch_data_get_type(resp);
    if (ldata_Type == LAUNCH_DATA_DICTIONARY) {
      dict = GTMCFTypeCreateFromLaunchData(resp, true, &error);
    } else {
      error = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                                CFSTR("Unknown launchd type %d"),
                                                ldata_Type);
    }
    launch_data_free(resp);
  }
  if (error) {
    CFShow(error);
    CFRelease(error);
  }
  return dict;
}

CFDictionaryRef GTMSMCopyAllJobDictionaries(void) {
  CFDictionaryRef dict = NULL;
  launch_data_t msg = launch_data_new_string(LAUNCH_KEY_GETJOBS);
  launch_data_t resp = launch_msg(msg);
  launch_data_free(msg);
  CFErrorRef error = NULL;

  if (resp) {
    launch_data_type_t ldata_Type = launch_data_get_type(resp);
    if (ldata_Type == LAUNCH_DATA_DICTIONARY) {
      dict = GTMCFTypeCreateFromLaunchData(resp, true, &error);
    } else {
      error = GTMCFLaunchCreateUnlocalizedError(EINVAL,
                                                CFSTR("Unknown launchd type %d"),
                                                ldata_Type);
    }
    launch_data_free(resp);
  } else {
    error
      = GTMCFLaunchCreateUnlocalizedError(errno, CFSTR(""));
  }
  if (error) {
    CFShow(error);
    CFRelease(error);
  }
  return dict;
}

#endif //  if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4
