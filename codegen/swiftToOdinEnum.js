const swiftCode = `public var errSecNoSuchKeychain: OSStatus { get } /* The specified keychain could not be found. */
public var errSecInvalidKeychain: OSStatus { get } /* The specified keychain is not a valid keychain file. */
public var errSecDuplicateKeychain: OSStatus { get } /* A keychain with the same name already exists. */
public var errSecDuplicateCallback: OSStatus { get } /* The specified callback function is already installed. */
public var errSecInvalidCallback: OSStatus { get } /* The specified callback function is not valid. */
public var errSecDuplicateItem: OSStatus { get } /* The specified item already exists in the keychain. */
public var errSecItemNotFound: OSStatus { get } /* The specified item could not be found in the keychain. */
public var errSecBufferTooSmall: OSStatus { get } /* There is not enough memory available to use the specified item. */
public var errSecDataTooLarge: OSStatus { get } /* This item contains information which is too large or in a format that cannot be displayed. */
public var errSecNoSuchAttr: OSStatus { get } /* The specified attribute does not exist. */
public var errSecInvalidItemRef: OSStatus { get } /* The specified item is no longer valid. It may have been deleted from the keychain. */
public var errSecInvalidSearchRef: OSStatus { get } /* Unable to search the current keychain. */
public var errSecNoSuchClass: OSStatus { get } /* The specified item does not appear to be a valid keychain item. */
public var errSecNoDefaultKeychain: OSStatus { get } /* A default keychain could not be found. */
public var errSecInteractionNotAllowed: OSStatus { get } /* User interaction is not allowed. */
public var errSecReadOnlyAttr: OSStatus { get } /* The specified attribute could not be modified. */
public var errSecWrongSecVersion: OSStatus { get } /* This keychain was created by a different version of the system software and cannot be opened. */
public var errSecKeySizeNotAllowed: OSStatus { get } /* This item specifies a key size which is too large or too small. */
public var errSecNoStorageModule: OSStatus { get } /* A required component (data storage module) could not be loaded. You may need to restart your computer. */
public var errSecNoCertificateModule: OSStatus { get } /* A required component (certificate module) could not be loaded. You may need to restart your computer. */
public var errSecNoPolicyModule: OSStatus { get } /* A required component (policy module) could not be loaded. You may need to restart your computer. */
public var errSecInteractionRequired: OSStatus { get } /* User interaction is required, but is currently not allowed. */
public var errSecDataNotAvailable: OSStatus { get } /* The contents of this item cannot be retrieved. */
public var errSecDataNotModifiable: OSStatus { get } /* The contents of this item cannot be modified. */
public var errSecCreateChainFailed: OSStatus { get } /* One or more certificates required to validate this certificate cannot be found. */
public var errSecInvalidPrefsDomain: OSStatus { get } /* The specified preferences domain is not valid. */
public var errSecInDarkWake: OSStatus { get } /* In dark wake, no UI possible */
public var errSecACLNotSimple: OSStatus { get } /* The specified access control list is not in standard (simple) form. */
public var errSecPolicyNotFound: OSStatus { get } /* The specified policy cannot be found. */
public var errSecInvalidTrustSetting: OSStatus { get } /* The specified trust setting is invalid. */
public var errSecNoAccessForItem: OSStatus { get } /* The specified item has no access control. */
public var errSecInvalidOwnerEdit: OSStatus { get } /* Invalid attempt to change the owner of this item. */
public var errSecTrustNotAvailable: OSStatus { get } /* No trust results are available. */
public var errSecUnsupportedFormat: OSStatus { get } /* Import/Export format unsupported. */
public var errSecUnknownFormat: OSStatus { get } /* Unknown format in import. */
public var errSecKeyIsSensitive: OSStatus { get } /* Key material must be wrapped for export. */
public var errSecMultiplePrivKeys: OSStatus { get } /* An attempt was made to import multiple private keys. */
public var errSecPassphraseRequired: OSStatus { get } /* Passphrase is required for import/export. */
public var errSecInvalidPasswordRef: OSStatus { get } /* The password reference was invalid. */
public var errSecInvalidTrustSettings: OSStatus { get } /* The Trust Settings Record was corrupted. */
public var errSecNoTrustSettings: OSStatus { get } /* No Trust Settings were found. */
public var errSecPkcs12VerifyFailure: OSStatus { get } /* MAC verification failed during PKCS12 import (wrong password?) */
public var errSecNotSigner: OSStatus { get } /* A certificate was not signed by its proposed parent. */
public var errSecDecode: OSStatus { get } /* Unable to decode the provided data. */
public var errSecServiceNotAvailable: OSStatus { get } /* The required service is not available. */
public var errSecInsufficientClientID: OSStatus { get } /* The client ID is not correct. */
public var errSecDeviceReset: OSStatus { get } /* A device reset has occurred. */
public var errSecDeviceFailed: OSStatus { get } /* A device failure has occurred. */
public var errSecAppleAddAppACLSubject: OSStatus { get } /* Adding an application ACL subject failed. */
public var errSecApplePublicKeyIncomplete: OSStatus { get } /* The public key is incomplete. */
public var errSecAppleSignatureMismatch: OSStatus { get } /* A signature mismatch has occurred. */
public var errSecAppleInvalidKeyStartDate: OSStatus { get } /* The specified key has an invalid start date. */
public var errSecAppleInvalidKeyEndDate: OSStatus { get } /* The specified key has an invalid end date. */
public var errSecConversionError: OSStatus { get } /* A conversion error has occurred. */
public var errSecAppleSSLv2Rollback: OSStatus { get } /* A SSLv2 rollback error has occurred. */
public var errSecQuotaExceeded: OSStatus { get } /* The quota was exceeded. */
public var errSecFileTooBig: OSStatus { get } /* The file is too big. */
public var errSecInvalidDatabaseBlob: OSStatus { get } /* The specified database has an invalid blob. */
public var errSecInvalidKeyBlob: OSStatus { get } /* The specified database has an invalid key blob. */
public var errSecIncompatibleDatabaseBlob: OSStatus { get } /* The specified database has an incompatible blob. */
public var errSecIncompatibleKeyBlob: OSStatus { get } /* The specified database has an incompatible key blob. */
public var errSecHostNameMismatch: OSStatus { get } /* A host name mismatch has occurred. */
public var errSecUnknownCriticalExtensionFlag: OSStatus { get } /* There is an unknown critical extension flag. */
public var errSecNoBasicConstraints: OSStatus { get } /* No basic constraints were found. */
public var errSecNoBasicConstraintsCA: OSStatus { get } /* No basic CA constraints were found. */
public var errSecInvalidAuthorityKeyID: OSStatus { get } /* The authority key ID is not valid. */
public var errSecInvalidSubjectKeyID: OSStatus { get } /* The subject key ID is not valid. */
public var errSecInvalidKeyUsageForPolicy: OSStatus { get } /* The key usage is not valid for the specified policy. */
public var errSecInvalidExtendedKeyUsage: OSStatus { get } /* The extended key usage is not valid. */
public var errSecInvalidIDLinkage: OSStatus { get } /* The ID linkage is not valid. */
public var errSecPathLengthConstraintExceeded: OSStatus { get } /* The path length constraint was exceeded. */
public var errSecInvalidRoot: OSStatus { get } /* The root or anchor certificate is not valid. */
public var errSecCRLExpired: OSStatus { get } /* The CRL has expired. */
public var errSecCRLNotValidYet: OSStatus { get } /* The CRL is not yet valid. */
public var errSecCRLNotFound: OSStatus { get } /* The CRL was not found. */
public var errSecCRLServerDown: OSStatus { get } /* The CRL server is down. */
public var errSecCRLBadURI: OSStatus { get } /* The CRL has a bad Uniform Resource Identifier. */
public var errSecUnknownCertExtension: OSStatus { get } /* An unknown certificate extension was encountered. */
public var errSecUnknownCRLExtension: OSStatus { get } /* An unknown CRL extension was encountered. */
public var errSecCRLNotTrusted: OSStatus { get } /* The CRL is not trusted. */
public var errSecCRLPolicyFailed: OSStatus { get } /* The CRL policy failed. */
public var errSecIDPFailure: OSStatus { get } /* The issuing distribution point was not valid. */
public var errSecSMIMEEmailAddressesNotFound: OSStatus { get } /* An email address mismatch was encountered. */
public var errSecSMIMEBadExtendedKeyUsage: OSStatus { get } /* The appropriate extended key usage for SMIME was not found. */
public var errSecSMIMEBadKeyUsage: OSStatus { get } /* The key usage is not compatible with SMIME. */
public var errSecSMIMEKeyUsageNotCritical: OSStatus { get } /* The key usage extension is not marked as critical. */
public var errSecSMIMENoEmailAddress: OSStatus { get } /* No email address was found in the certificate. */
public var errSecSMIMESubjAltNameNotCritical: OSStatus { get } /* The subject alternative name extension is not marked as critical. */
public var errSecSSLBadExtendedKeyUsage: OSStatus { get } /* The appropriate extended key usage for SSL was not found. */
public var errSecOCSPBadResponse: OSStatus { get } /* The OCSP response was incorrect or could not be parsed. */
public var errSecOCSPBadRequest: OSStatus { get } /* The OCSP request was incorrect or could not be parsed. */
public var errSecOCSPUnavailable: OSStatus { get } /* OCSP service is unavailable. */
public var errSecOCSPStatusUnrecognized: OSStatus { get } /* The OCSP server did not recognize this certificate. */
public var errSecEndOfData: OSStatus { get } /* An end-of-data was detected. */
public var errSecIncompleteCertRevocationCheck: OSStatus { get } /* An incomplete certificate revocation check occurred. */
public var errSecNetworkFailure: OSStatus { get } /* A network failure occurred. */
public var errSecOCSPNotTrustedToAnchor: OSStatus { get } /* The OCSP response was not trusted to a root or anchor certificate. */
public var errSecRecordModified: OSStatus { get } /* The record was modified. */
public var errSecOCSPSignatureError: OSStatus { get } /* The OCSP response had an invalid signature. */
public var errSecOCSPNoSigner: OSStatus { get } /* The OCSP response had no signer. */
public var errSecOCSPResponderMalformedReq: OSStatus { get } /* The OCSP responder was given a malformed request. */
public var errSecOCSPResponderInternalError: OSStatus { get } /* The OCSP responder encountered an internal error. */
public var errSecOCSPResponderTryLater: OSStatus { get } /* The OCSP responder is busy, try again later. */
public var errSecOCSPResponderSignatureRequired: OSStatus { get } /* The OCSP responder requires a signature. */
public var errSecOCSPResponderUnauthorized: OSStatus { get } /* The OCSP responder rejected this request as unauthorized. */
public var errSecOCSPResponseNonceMismatch: OSStatus { get } /* The OCSP response nonce did not match the request. */
public var errSecCodeSigningBadCertChainLength: OSStatus { get } /* Code signing encountered an incorrect certificate chain length. */
public var errSecCodeSigningNoBasicConstraints: OSStatus { get } /* Code signing found no basic constraints. */
public var errSecCodeSigningBadPathLengthConstraint: OSStatus { get } /* Code signing encountered an incorrect path length constraint. */
public var errSecCodeSigningNoExtendedKeyUsage: OSStatus { get } /* Code signing found no extended key usage. */
public var errSecCodeSigningDevelopment: OSStatus { get } /* Code signing indicated use of a development-only certificate. */
public var errSecResourceSignBadCertChainLength: OSStatus { get } /* Resource signing has encountered an incorrect certificate chain length. */
public var errSecResourceSignBadExtKeyUsage: OSStatus { get } /* Resource signing has encountered an error in the extended key usage. */
public var errSecTrustSettingDeny: OSStatus { get } /* The trust setting for this policy was set to Deny. */
public var errSecInvalidSubjectName: OSStatus { get } /* An invalid certificate subject name was encountered. */
public var errSecUnknownQualifiedCertStatement: OSStatus { get } /* An unknown qualified certificate statement was encountered. */
public var errSecMobileMeRequestQueued: OSStatus { get }
public var errSecMobileMeRequestRedirected: OSStatus { get }
public var errSecMobileMeServerError: OSStatus { get }
public var errSecMobileMeServerNotAvailable: OSStatus { get }
public var errSecMobileMeServerAlreadyExists: OSStatus { get }
public var errSecMobileMeServerServiceErr: OSStatus { get }
public var errSecMobileMeRequestAlreadyPending: OSStatus { get }
public var errSecMobileMeNoRequestPending: OSStatus { get }
public var errSecMobileMeCSRVerifyFailure: OSStatus { get }
public var errSecMobileMeFailedConsistencyCheck: OSStatus { get }
public var errSecNotInitialized: OSStatus { get } /* A function was called without initializing CSSM. */
public var errSecInvalidHandleUsage: OSStatus { get } /* The CSSM handle does not match with the service type. */
public var errSecPVCReferentNotFound: OSStatus { get } /* A reference to the calling module was not found in the list of authorized callers. */
public var errSecFunctionIntegrityFail: OSStatus { get } /* A function address was not within the verified module. */
public var errSecInternalError: OSStatus { get } /* An internal error has occurred. */
public var errSecMemoryError: OSStatus { get } /* A memory error has occurred. */
public var errSecInvalidData: OSStatus { get } /* Invalid data was encountered. */
public var errSecMDSError: OSStatus { get } /* A Module Directory Service error has occurred. */
public var errSecInvalidPointer: OSStatus { get } /* An invalid pointer was encountered. */
public var errSecSelfCheckFailed: OSStatus { get } /* Self-check has failed. */
public var errSecFunctionFailed: OSStatus { get } /* A function has failed. */
public var errSecModuleManifestVerifyFailed: OSStatus { get } /* A module manifest verification failure has occurred. */
public var errSecInvalidGUID: OSStatus { get } /* An invalid GUID was encountered. */
public var errSecInvalidHandle: OSStatus { get } /* An invalid handle was encountered. */
public var errSecInvalidDBList: OSStatus { get } /* An invalid DB list was encountered. */
public var errSecInvalidPassthroughID: OSStatus { get } /* An invalid passthrough ID was encountered. */
public var errSecInvalidNetworkAddress: OSStatus { get } /* An invalid network address was encountered. */
public var errSecCRLAlreadySigned: OSStatus { get } /* The certificate revocation list is already signed. */
public var errSecInvalidNumberOfFields: OSStatus { get } /* An invalid number of fields were encountered. */
public var errSecVerificationFailure: OSStatus { get } /* A verification failure occurred. */
public var errSecUnknownTag: OSStatus { get } /* An unknown tag was encountered. */
public var errSecInvalidSignature: OSStatus { get } /* An invalid signature was encountered. */
public var errSecInvalidName: OSStatus { get } /* An invalid name was encountered. */
public var errSecInvalidCertificateRef: OSStatus { get } /* An invalid certificate reference was encountered. */
public var errSecInvalidCertificateGroup: OSStatus { get } /* An invalid certificate group was encountered. */
public var errSecTagNotFound: OSStatus { get } /* The specified tag was not found. */
public var errSecInvalidQuery: OSStatus { get } /* The specified query was not valid. */
public var errSecInvalidValue: OSStatus { get } /* An invalid value was detected. */
public var errSecCallbackFailed: OSStatus { get } /* A callback has failed. */
public var errSecACLDeleteFailed: OSStatus { get } /* An ACL delete operation has failed. */
public var errSecACLReplaceFailed: OSStatus { get } /* An ACL replace operation has failed. */
public var errSecACLAddFailed: OSStatus { get } /* An ACL add operation has failed. */
public var errSecACLChangeFailed: OSStatus { get } /* An ACL change operation has failed. */
public var errSecInvalidAccessCredentials: OSStatus { get } /* Invalid access credentials were encountered. */
public var errSecInvalidRecord: OSStatus { get } /* An invalid record was encountered. */
public var errSecInvalidACL: OSStatus { get } /* An invalid ACL was encountered. */
public var errSecInvalidSampleValue: OSStatus { get } /* An invalid sample value was encountered. */
public var errSecIncompatibleVersion: OSStatus { get } /* An incompatible version was encountered. */
public var errSecPrivilegeNotGranted: OSStatus { get } /* The privilege was not granted. */
public var errSecInvalidScope: OSStatus { get } /* An invalid scope was encountered. */
public var errSecPVCAlreadyConfigured: OSStatus { get } /* The PVC is already configured. */
public var errSecInvalidPVC: OSStatus { get } /* An invalid PVC was encountered. */
public var errSecEMMLoadFailed: OSStatus { get } /* The EMM load has failed. */
public var errSecEMMUnloadFailed: OSStatus { get } /* The EMM unload has failed. */
public var errSecAddinLoadFailed: OSStatus { get } /* The add-in load operation has failed. */
public var errSecInvalidKeyRef: OSStatus { get } /* An invalid key was encountered. */
public var errSecInvalidKeyHierarchy: OSStatus { get } /* An invalid key hierarchy was encountered. */
public var errSecAddinUnloadFailed: OSStatus { get } /* The add-in unload operation has failed. */
public var errSecLibraryReferenceNotFound: OSStatus { get } /* A library reference was not found. */
public var errSecInvalidAddinFunctionTable: OSStatus { get } /* An invalid add-in function table was encountered. */
public var errSecInvalidServiceMask: OSStatus { get } /* An invalid service mask was encountered. */
public var errSecModuleNotLoaded: OSStatus { get } /* A module was not loaded. */
public var errSecInvalidSubServiceID: OSStatus { get } /* An invalid subservice ID was encountered. */
public var errSecAttributeNotInContext: OSStatus { get } /* An attribute was not in the context. */
public var errSecModuleManagerInitializeFailed: OSStatus { get } /* A module failed to initialize. */
public var errSecModuleManagerNotFound: OSStatus { get } /* A module was not found. */
public var errSecEventNotificationCallbackNotFound: OSStatus { get } /* An event notification callback was not found. */
public var errSecInputLengthError: OSStatus { get } /* An input length error was encountered. */
public var errSecOutputLengthError: OSStatus { get } /* An output length error was encountered. */
public var errSecPrivilegeNotSupported: OSStatus { get } /* The privilege is not supported. */
public var errSecDeviceError: OSStatus { get } /* A device error was encountered. */
public var errSecAttachHandleBusy: OSStatus { get } /* The CSP handle was busy. */
public var errSecNotLoggedIn: OSStatus { get } /* You are not logged in. */
public var errSecAlgorithmMismatch: OSStatus { get } /* An algorithm mismatch was encountered. */
public var errSecKeyUsageIncorrect: OSStatus { get } /* The key usage is incorrect. */
public var errSecKeyBlobTypeIncorrect: OSStatus { get } /* The key blob type is incorrect. */
public var errSecKeyHeaderInconsistent: OSStatus { get } /* The key header is inconsistent. */
public var errSecUnsupportedKeyFormat: OSStatus { get } /* The key header format is not supported. */
public var errSecUnsupportedKeySize: OSStatus { get } /* The key size is not supported. */
public var errSecInvalidKeyUsageMask: OSStatus { get } /* The key usage mask is not valid. */
public var errSecUnsupportedKeyUsageMask: OSStatus { get } /* The key usage mask is not supported. */
public var errSecInvalidKeyAttributeMask: OSStatus { get } /* The key attribute mask is not valid. */
public var errSecUnsupportedKeyAttributeMask: OSStatus { get } /* The key attribute mask is not supported. */
public var errSecInvalidKeyLabel: OSStatus { get } /* The key label is not valid. */
public var errSecUnsupportedKeyLabel: OSStatus { get } /* The key label is not supported. */
public var errSecInvalidKeyFormat: OSStatus { get } /* The key format is not valid. */
public var errSecUnsupportedVectorOfBuffers: OSStatus { get } /* The vector of buffers is not supported. */
public var errSecInvalidInputVector: OSStatus { get } /* The input vector is not valid. */
public var errSecInvalidOutputVector: OSStatus { get } /* The output vector is not valid. */
public var errSecInvalidContext: OSStatus { get } /* An invalid context was encountered. */
public var errSecInvalidAlgorithm: OSStatus { get } /* An invalid algorithm was encountered. */
public var errSecInvalidAttributeKey: OSStatus { get } /* A key attribute was not valid. */
public var errSecMissingAttributeKey: OSStatus { get } /* A key attribute was missing. */
public var errSecInvalidAttributeInitVector: OSStatus { get } /* An init vector attribute was not valid. */
public var errSecMissingAttributeInitVector: OSStatus { get } /* An init vector attribute was missing. */
public var errSecInvalidAttributeSalt: OSStatus { get } /* A salt attribute was not valid. */
public var errSecMissingAttributeSalt: OSStatus { get } /* A salt attribute was missing. */
public var errSecInvalidAttributePadding: OSStatus { get } /* A padding attribute was not valid. */
public var errSecMissingAttributePadding: OSStatus { get } /* A padding attribute was missing. */
public var errSecInvalidAttributeRandom: OSStatus { get } /* A random number attribute was not valid. */
public var errSecMissingAttributeRandom: OSStatus { get } /* A random number attribute was missing. */
public var errSecInvalidAttributeSeed: OSStatus { get } /* A seed attribute was not valid. */
public var errSecMissingAttributeSeed: OSStatus { get } /* A seed attribute was missing. */
public var errSecInvalidAttributePassphrase: OSStatus { get } /* A passphrase attribute was not valid. */
public var errSecMissingAttributePassphrase: OSStatus { get } /* A passphrase attribute was missing. */
public var errSecInvalidAttributeKeyLength: OSStatus { get } /* A key length attribute was not valid. */
public var errSecMissingAttributeKeyLength: OSStatus { get } /* A key length attribute was missing. */
public var errSecInvalidAttributeBlockSize: OSStatus { get } /* A block size attribute was not valid. */
public var errSecMissingAttributeBlockSize: OSStatus { get } /* A block size attribute was missing. */
public var errSecInvalidAttributeOutputSize: OSStatus { get } /* An output size attribute was not valid. */
public var errSecMissingAttributeOutputSize: OSStatus { get } /* An output size attribute was missing. */
public var errSecInvalidAttributeRounds: OSStatus { get } /* The number of rounds attribute was not valid. */
public var errSecMissingAttributeRounds: OSStatus { get } /* The number of rounds attribute was missing. */
public var errSecInvalidAlgorithmParms: OSStatus { get } /* An algorithm parameters attribute was not valid. */
public var errSecMissingAlgorithmParms: OSStatus { get } /* An algorithm parameters attribute was missing. */
public var errSecInvalidAttributeLabel: OSStatus { get } /* A label attribute was not valid. */
public var errSecMissingAttributeLabel: OSStatus { get } /* A label attribute was missing. */
public var errSecInvalidAttributeKeyType: OSStatus { get } /* A key type attribute was not valid. */
public var errSecMissingAttributeKeyType: OSStatus { get } /* A key type attribute was missing. */
public var errSecInvalidAttributeMode: OSStatus { get } /* A mode attribute was not valid. */
public var errSecMissingAttributeMode: OSStatus { get } /* A mode attribute was missing. */
public var errSecInvalidAttributeEffectiveBits: OSStatus { get } /* An effective bits attribute was not valid. */
public var errSecMissingAttributeEffectiveBits: OSStatus { get } /* An effective bits attribute was missing. */
public var errSecInvalidAttributeStartDate: OSStatus { get } /* A start date attribute was not valid. */
public var errSecMissingAttributeStartDate: OSStatus { get } /* A start date attribute was missing. */
public var errSecInvalidAttributeEndDate: OSStatus { get } /* An end date attribute was not valid. */
public var errSecMissingAttributeEndDate: OSStatus { get } /* An end date attribute was missing. */
public var errSecInvalidAttributeVersion: OSStatus { get } /* A version attribute was not valid. */
public var errSecMissingAttributeVersion: OSStatus { get } /* A version attribute was missing. */
public var errSecInvalidAttributePrime: OSStatus { get } /* A prime attribute was not valid. */
public var errSecMissingAttributePrime: OSStatus { get } /* A prime attribute was missing. */
public var errSecInvalidAttributeBase: OSStatus { get } /* A base attribute was not valid. */
public var errSecMissingAttributeBase: OSStatus { get } /* A base attribute was missing. */
public var errSecInvalidAttributeSubprime: OSStatus { get } /* A subprime attribute was not valid. */
public var errSecMissingAttributeSubprime: OSStatus { get } /* A subprime attribute was missing. */
public var errSecInvalidAttributeIterationCount: OSStatus { get } /* An iteration count attribute was not valid. */
public var errSecMissingAttributeIterationCount: OSStatus { get } /* An iteration count attribute was missing. */
public var errSecInvalidAttributeDLDBHandle: OSStatus { get } /* A database handle attribute was not valid. */
public var errSecMissingAttributeDLDBHandle: OSStatus { get } /* A database handle attribute was missing. */
public var errSecInvalidAttributeAccessCredentials: OSStatus { get } /* An access credentials attribute was not valid. */
public var errSecMissingAttributeAccessCredentials: OSStatus { get } /* An access credentials attribute was missing. */
public var errSecInvalidAttributePublicKeyFormat: OSStatus { get } /* A public key format attribute was not valid. */
public var errSecMissingAttributePublicKeyFormat: OSStatus { get } /* A public key format attribute was missing. */
public var errSecInvalidAttributePrivateKeyFormat: OSStatus { get } /* A private key format attribute was not valid. */
public var errSecMissingAttributePrivateKeyFormat: OSStatus { get } /* A private key format attribute was missing. */
public var errSecInvalidAttributeSymmetricKeyFormat: OSStatus { get } /* A symmetric key format attribute was not valid. */
public var errSecMissingAttributeSymmetricKeyFormat: OSStatus { get } /* A symmetric key format attribute was missing. */
public var errSecInvalidAttributeWrappedKeyFormat: OSStatus { get } /* A wrapped key format attribute was not valid. */
public var errSecMissingAttributeWrappedKeyFormat: OSStatus { get } /* A wrapped key format attribute was missing. */
public var errSecStagedOperationInProgress: OSStatus { get } /* A staged operation is in progress. */
public var errSecStagedOperationNotStarted: OSStatus { get } /* A staged operation was not started. */
public var errSecVerifyFailed: OSStatus { get } /* A cryptographic verification failure has occurred. */
public var errSecQuerySizeUnknown: OSStatus { get } /* The query size is unknown. */
public var errSecBlockSizeMismatch: OSStatus { get } /* A block size mismatch occurred. */
public var errSecPublicKeyInconsistent: OSStatus { get } /* The public key was inconsistent. */
public var errSecDeviceVerifyFailed: OSStatus { get } /* A device verification failure has occurred. */
public var errSecInvalidLoginName: OSStatus { get } /* An invalid login name was detected. */
public var errSecAlreadyLoggedIn: OSStatus { get } /* The user is already logged in. */
public var errSecInvalidDigestAlgorithm: OSStatus { get } /* An invalid digest algorithm was detected. */
public var errSecInvalidCRLGroup: OSStatus { get } /* An invalid CRL group was detected. */
public var errSecCertificateCannotOperate: OSStatus { get } /* The certificate cannot operate. */
public var errSecCertificateExpired: OSStatus { get } /* An expired certificate was detected. */
public var errSecCertificateNotValidYet: OSStatus { get } /* The certificate is not yet valid. */
public var errSecCertificateRevoked: OSStatus { get } /* The certificate was revoked. */
public var errSecCertificateSuspended: OSStatus { get } /* The certificate was suspended. */
public var errSecInsufficientCredentials: OSStatus { get } /* Insufficient credentials were detected. */
public var errSecInvalidAction: OSStatus { get } /* The action was not valid. */
public var errSecInvalidAuthority: OSStatus { get } /* The authority was not valid. */
public var errSecVerifyActionFailed: OSStatus { get } /* A verify action has failed. */
public var errSecInvalidCertAuthority: OSStatus { get } /* The certificate authority was not valid. */
public var errSecInvalidCRLAuthority: OSStatus { get } /* The CRL authority was not valid. */
public var errSecInvalidCRLEncoding: OSStatus { get } /* The CRL encoding was not valid. */
public var errSecInvalidCRLType: OSStatus { get } /* The CRL type was not valid. */
public var errSecInvalidCRL: OSStatus { get } /* The CRL was not valid. */
public var errSecInvalidFormType: OSStatus { get } /* The form type was not valid. */
public var errSecInvalidID: OSStatus { get } /* The ID was not valid. */
public var errSecInvalidIdentifier: OSStatus { get } /* The identifier was not valid. */
public var errSecInvalidIndex: OSStatus { get } /* The index was not valid. */
public var errSecInvalidPolicyIdentifiers: OSStatus { get } /* The policy identifiers are not valid. */
public var errSecInvalidTimeString: OSStatus { get } /* The time specified was not valid. */
public var errSecInvalidReason: OSStatus { get } /* The trust policy reason was not valid. */
public var errSecInvalidRequestInputs: OSStatus { get } /* The request inputs are not valid. */
public var errSecInvalidResponseVector: OSStatus { get } /* The response vector was not valid. */
public var errSecInvalidStopOnPolicy: OSStatus { get } /* The stop-on policy was not valid. */
public var errSecInvalidTuple: OSStatus { get } /* The tuple was not valid. */
public var errSecMultipleValuesUnsupported: OSStatus { get } /* Multiple values are not supported. */
public var errSecNotTrusted: OSStatus { get } /* The certificate was not trusted. */
public var errSecNoDefaultAuthority: OSStatus { get } /* No default authority was detected. */
public var errSecRejectedForm: OSStatus { get } /* The trust policy had a rejected form. */
public var errSecRequestLost: OSStatus { get } /* The request was lost. */
public var errSecRequestRejected: OSStatus { get } /* The request was rejected. */
public var errSecUnsupportedAddressType: OSStatus { get } /* The address type is not supported. */
public var errSecUnsupportedService: OSStatus { get } /* The service is not supported. */
public var errSecInvalidTupleGroup: OSStatus { get } /* The tuple group was not valid. */
public var errSecInvalidBaseACLs: OSStatus { get } /* The base ACLs are not valid. */
public var errSecInvalidTupleCredentials: OSStatus { get } /* The tuple credentials are not valid. */
public var errSecInvalidEncoding: OSStatus { get } /* The encoding was not valid. */
public var errSecInvalidValidityPeriod: OSStatus { get } /* The validity period was not valid. */
public var errSecInvalidRequestor: OSStatus { get } /* The requestor was not valid. */
public var errSecRequestDescriptor: OSStatus { get } /* The request descriptor was not valid. */
public var errSecInvalidBundleInfo: OSStatus { get } /* The bundle information was not valid. */
public var errSecInvalidCRLIndex: OSStatus { get } /* The CRL index was not valid. */
public var errSecNoFieldValues: OSStatus { get } /* No field values were detected. */
public var errSecUnsupportedFieldFormat: OSStatus { get } /* The field format is not supported. */
public var errSecUnsupportedIndexInfo: OSStatus { get } /* The index information is not supported. */
public var errSecUnsupportedLocality: OSStatus { get } /* The locality is not supported. */
public var errSecUnsupportedNumAttributes: OSStatus { get } /* The number of attributes is not supported. */
public var errSecUnsupportedNumIndexes: OSStatus { get } /* The number of indexes is not supported. */
public var errSecUnsupportedNumRecordTypes: OSStatus { get } /* The number of record types is not supported. */
public var errSecFieldSpecifiedMultiple: OSStatus { get } /* Too many fields were specified. */
public var errSecIncompatibleFieldFormat: OSStatus { get } /* The field format was incompatible. */
public var errSecInvalidParsingModule: OSStatus { get } /* The parsing module was not valid. */
public var errSecDatabaseLocked: OSStatus { get } /* The database is locked. */
public var errSecDatastoreIsOpen: OSStatus { get } /* The data store is open. */
public var errSecMissingValue: OSStatus { get } /* A missing value was detected. */
public var errSecUnsupportedQueryLimits: OSStatus { get } /* The query limits are not supported. */
public var errSecUnsupportedNumSelectionPreds: OSStatus { get } /* The number of selection predicates is not supported. */
public var errSecUnsupportedOperator: OSStatus { get } /* The operator is not supported. */
public var errSecInvalidDBLocation: OSStatus { get } /* The database location is not valid. */
public var errSecInvalidAccessRequest: OSStatus { get } /* The access request is not valid. */
public var errSecInvalidIndexInfo: OSStatus { get } /* The index information is not valid. */
public var errSecInvalidNewOwner: OSStatus { get } /* The new owner is not valid. */
public var errSecInvalidModifyMode: OSStatus { get } /* The modify mode is not valid. */
public var errSecMissingRequiredExtension: OSStatus { get } /* A required certificate extension is missing. */
public var errSecExtendedKeyUsageNotCritical: OSStatus { get } /* The extended key usage extension was not marked critical. */
public var errSecTimestampMissing: OSStatus { get } /* A timestamp was expected but was not found. */
public var errSecTimestampInvalid: OSStatus { get } /* The timestamp was not valid. */
public var errSecTimestampNotTrusted: OSStatus { get } /* The timestamp was not trusted. */
public var errSecTimestampServiceNotAvailable: OSStatus { get } /* The timestamp service is not available. */
public var errSecTimestampBadAlg: OSStatus { get } /* An unrecognized or unsupported Algorithm Identifier in timestamp. */
public var errSecTimestampBadRequest: OSStatus { get } /* The timestamp transaction is not permitted or supported. */
public var errSecTimestampBadDataFormat: OSStatus { get } /* The timestamp data submitted has the wrong format. */
public var errSecTimestampTimeNotAvailable: OSStatus { get } /* The time source for the Timestamp Authority is not available. */
public var errSecTimestampUnacceptedPolicy: OSStatus { get } /* The requested policy is not supported by the Timestamp Authority. */
public var errSecTimestampUnacceptedExtension: OSStatus { get } /* The requested extension is not supported by the Timestamp Authority. */
public var errSecTimestampAddInfoNotAvailable: OSStatus { get } /* The additional information requested is not available. */
public var errSecTimestampSystemFailure: OSStatus { get } /* The timestamp request cannot be handled due to system failure. */
public var errSecSigningTimeMissing: OSStatus { get } /* A signing time was expected but was not found. */
public var errSecTimestampRejection: OSStatus { get } /* A timestamp transaction was rejected. */
public var errSecTimestampWaiting: OSStatus { get } /* A timestamp transaction is waiting. */
public var errSecTimestampRevocationWarning: OSStatus { get } /* A timestamp authority revocation warning was issued. */
public var errSecTimestampRevocationNotification: OSStatus { get } /* A timestamp authority revocation notification was issued. */
public var errSecCertificatePolicyNotAllowed: OSStatus { get } /* The requested policy is not allowed for this certificate. */
public var errSecCertificateNameNotAllowed: OSStatus { get } /* The requested name is not allowed for this certificate. */
public var errSecCertificateValidityPeriodTooLong: OSStatus { get } /* The validity period in the certificate exceeds the maximum allowed. */
public var errSecCertificateIsCA: OSStatus { get } /* The verified certificate is a CA rather than an end-entity. */
public var errSecCertificateDuplicateExtension: OSStatus { get } /* The certificate contains multiple extensions with the same extension ID. */`;

const lines = swiftCode.split('\n');

const out = lines.map(line => {
  const colonPos = line.indexOf(':');
  const openCommentPos = line.indexOf('/*');
  const closeCommentPos = line.indexOf('*/');
  const hasComment = openCommentPos >= 0 && closeCommentPos >= 0 && closeCommentPos > openCommentPos;
  const comment = hasComment ? ` \/\/ ${line.substring(openCommentPos + 3, closeCommentPos - 1)}` : '';
  const constName = line.substring(11, colonPos);
  const swiftPrintToOdinEnum = `print("${constName} = \\(${constName}),${comment}")`;
  return swiftPrintToOdinEnum;
});

console.log(out.join('\n'));