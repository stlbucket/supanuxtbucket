import type { ColumnType } from "kysely";

export type AppExpirationIntervalType = "day" | "explicit" | "month" | "none" | "quarter" | "week" | "year";

export type AppLicenseStatus = "active" | "expired" | "inactive";

export type AppLicenseTypeAssignmentScope = "admin" | "all" | "none" | "superadmin" | "support" | "user";

export type AppProfileStatus = "active" | "blocked" | "inactive";

export type AppResidentStatus = "active" | "blocked_individual" | "blocked_tenant" | "declined" | "inactive" | "invited" | "supporting";

export type AppResidentType = "guest" | "home" | "support";

export type AppTenantStatus = "active" | "inactive" | "paused";

export type AppTenantType = "anchor" | "customer" | "demo" | "test" | "trial";

export type AuthAalLevel = "aal1" | "aal2" | "aal3";

export type AuthCodeChallengeMethod = "plain" | "s256";

export type AuthFactorStatus = "unverified" | "verified";

export type AuthFactorType = "totp" | "webauthn";

export type Generated<T> = T extends ColumnType<infer S, infer I, infer U>
  ? ColumnType<S, I | undefined, U>
  : ColumnType<T, T | undefined, T>;

export type IncIncidentStatus = "aborted" | "closed" | "open" | "pending" | "reported";

export type Int8 = ColumnType<string, string | number | bigint, string | number | bigint>;

export type Json = ColumnType<JsonValue, string, string>;

export type JsonArray = JsonValue[];

export type JsonObject = {
  [K in string]?: JsonValue;
};

export type JsonPrimitive = boolean | null | number | string;

export type JsonValue = JsonArray | JsonObject | JsonPrimitive;

export type MsgMessageStatus = "deleted" | "draft" | "sent";

export type MsgSubscriberStatus = "active" | "blocked" | "inactive";

export type MsgTopicStatus = "closed" | "locked" | "open";

export type Numeric = ColumnType<string, string | number, string | number>;

export type PgsodiumKeyStatus = "default" | "expired" | "invalid" | "valid";

export type PgsodiumKeyType = "aead-det" | "aead-ietf" | "auth" | "generichash" | "hmacsha256" | "hmacsha512" | "kdf" | "secretbox" | "secretstream" | "shorthash" | "stream_xchacha20";

export type Timestamp = ColumnType<Date, Date | string, Date | string>;

export type TodoTodoStatus = "archived" | "complete" | "incomplete" | "unfinished";

export type TodoTodoType = "milestone" | "task";

export interface _RealtimeExtensions {
  id: string;
  type: string | null;
  settings: Json | null;
  tenantExternalId: string | null;
  insertedAt: Timestamp;
  updatedAt: Timestamp;
}

export interface _RealtimeSchemaMigrations {
  version: Int8;
  insertedAt: Timestamp | null;
}

export interface _RealtimeTenants {
  id: string;
  name: string | null;
  externalId: string | null;
  jwtSecret: string | null;
  maxConcurrentUsers: Generated<number>;
  insertedAt: Timestamp;
  updatedAt: Timestamp;
  maxEventsPerSecond: Generated<number>;
  postgresCdcDefault: Generated<string | null>;
  maxBytesPerSecond: Generated<number>;
  maxChannelsPerClient: Generated<number>;
  maxJoinsPerSecond: Generated<number>;
}

export interface AppApplication {
  key: string;
  name: string;
}

export interface AppAppSettings {
  key: string;
  applicationKey: string;
  displayName: string;
  value: string;
}

export interface AppLicense {
  id: Generated<string>;
  tenantId: string;
  residentId: string;
  tenantSubscriptionId: string;
  licenseTypeKey: string;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
  expiresAt: Timestamp | null;
  status: Generated<AppLicenseStatus>;
}

export interface AppLicensePack {
  key: string;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
  displayName: string;
  autoSubscribe: Generated<boolean>;
}

export interface AppLicensePackLicenseType {
  id: Generated<string>;
  licensePackKey: string;
  licenseTypeKey: string;
  numberOfLicenses: Generated<number>;
  expirationIntervalType: Generated<AppExpirationIntervalType>;
  expirationIntervalMultiplier: Generated<number>;
}

export interface AppLicenseType {
  key: string;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
  applicationKey: string;
  displayName: string;
  assignmentScope: AppLicenseTypeAssignmentScope;
}

export interface AppLicenseTypePermission {
  licenseTypeKey: string;
  permissionKey: string;
}

export interface AppPermission {
  key: string;
}

export interface AppProfile {
  id: string;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
  email: string;
  identifier: string | null;
  firstName: string | null;
  lastName: string | null;
  phone: string | null;
  displayName: string | null;
  avatarKey: string | null;
  status: Generated<AppProfileStatus>;
  isPublic: Generated<boolean>;
  fullName: Generated<string | null>;
}

export interface AppResident {
  id: Generated<string>;
  profileId: string | null;
  invitedByProfileId: string | null;
  invitedByDisplayName: string | null;
  tenantId: string;
  tenantName: string;
  email: string;
  displayName: string | null;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
  status: Generated<AppResidentStatus>;
  type: AppResidentType;
}

export interface AppTenant {
  id: Generated<string>;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
  identifier: string | null;
  name: string;
  type: Generated<AppTenantType>;
  status: Generated<AppTenantStatus>;
}

export interface AppTenantSubscription {
  id: Generated<string>;
  tenantId: string;
  licensePackKey: string;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
}

export interface AuthAuditLogEntries {
  instanceId: string | null;
  id: string;
  payload: Json | null;
  createdAt: Timestamp | null;
  ipAddress: Generated<string>;
}

export interface AuthFlowState {
  id: string;
  userId: string | null;
  authCode: string;
  codeChallengeMethod: AuthCodeChallengeMethod;
  codeChallenge: string;
  providerType: string;
  providerAccessToken: string | null;
  providerRefreshToken: string | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
  authenticationMethod: string;
}

export interface AuthIdentities {
  id: string;
  userId: string;
  identityData: Json;
  provider: string;
  lastSignInAt: Timestamp | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
  email: Generated<string | null>;
}

export interface AuthInstances {
  id: string;
  uuid: string | null;
  rawBaseConfig: string | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export interface AuthMfaAmrClaims {
  sessionId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  authenticationMethod: string;
  id: string;
}

export interface AuthMfaChallenges {
  id: string;
  factorId: string;
  createdAt: Timestamp;
  verifiedAt: Timestamp | null;
  ipAddress: string;
}

export interface AuthMfaFactors {
  id: string;
  userId: string;
  friendlyName: string | null;
  factorType: AuthFactorType;
  status: AuthFactorStatus;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  secret: string | null;
}

export interface AuthRefreshTokens {
  instanceId: string | null;
  id: Generated<Int8>;
  token: string | null;
  userId: string | null;
  revoked: boolean | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
  parent: string | null;
  sessionId: string | null;
}

export interface AuthSamlProviders {
  id: string;
  ssoProviderId: string;
  entityId: string;
  metadataXml: string;
  metadataUrl: string | null;
  attributeMapping: Json | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export interface AuthSamlRelayStates {
  id: string;
  ssoProviderId: string;
  requestId: string;
  forEmail: string | null;
  redirectTo: string | null;
  fromIpAddress: string | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export interface AuthSchemaMigrations {
  version: string;
}

export interface AuthSessions {
  id: string;
  userId: string;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
  factorId: string | null;
  aal: AuthAalLevel | null;
  notAfter: Timestamp | null;
}

export interface AuthSsoDomains {
  id: string;
  ssoProviderId: string;
  domain: string;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export interface AuthSsoProviders {
  id: string;
  resourceId: string | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export interface AuthUsers {
  instanceId: string | null;
  id: string;
  aud: string | null;
  role: string | null;
  email: string | null;
  encryptedPassword: string | null;
  emailConfirmedAt: Timestamp | null;
  invitedAt: Timestamp | null;
  confirmationToken: string | null;
  confirmationSentAt: Timestamp | null;
  recoveryToken: string | null;
  recoverySentAt: Timestamp | null;
  emailChangeTokenNew: string | null;
  emailChange: string | null;
  emailChangeSentAt: Timestamp | null;
  lastSignInAt: Timestamp | null;
  rawAppMetaData: Json | null;
  rawUserMetaData: Json | null;
  isSuperAdmin: boolean | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
  phone: Generated<string | null>;
  phoneConfirmedAt: Timestamp | null;
  phoneChange: Generated<string | null>;
  phoneChangeToken: Generated<string | null>;
  phoneChangeSentAt: Timestamp | null;
  confirmedAt: Generated<Timestamp | null>;
  emailChangeTokenCurrent: Generated<string | null>;
  emailChangeConfirmStatus: Generated<number | null>;
  bannedUntil: Timestamp | null;
  reauthenticationToken: Generated<string | null>;
  reauthenticationSentAt: Timestamp | null;
  isSsoUser: Generated<boolean>;
  deletedAt: Timestamp | null;
}

export interface ExtensionsPgStatStatements {
  userid: number | null;
  dbid: number | null;
  toplevel: boolean | null;
  queryid: Int8 | null;
  query: string | null;
  plans: Int8 | null;
  totalPlanTime: number | null;
  minPlanTime: number | null;
  maxPlanTime: number | null;
  meanPlanTime: number | null;
  stddevPlanTime: number | null;
  calls: Int8 | null;
  totalExecTime: number | null;
  minExecTime: number | null;
  maxExecTime: number | null;
  meanExecTime: number | null;
  stddevExecTime: number | null;
  rows: Int8 | null;
  sharedBlksHit: Int8 | null;
  sharedBlksRead: Int8 | null;
  sharedBlksDirtied: Int8 | null;
  sharedBlksWritten: Int8 | null;
  localBlksHit: Int8 | null;
  localBlksRead: Int8 | null;
  localBlksDirtied: Int8 | null;
  localBlksWritten: Int8 | null;
  tempBlksRead: Int8 | null;
  tempBlksWritten: Int8 | null;
  blkReadTime: number | null;
  blkWriteTime: number | null;
  tempBlkReadTime: number | null;
  tempBlkWriteTime: number | null;
  walRecords: Int8 | null;
  walFpi: Int8 | null;
  walBytes: Numeric | null;
  jitFunctions: Int8 | null;
  jitGenerationTime: number | null;
  jitInliningCount: Int8 | null;
  jitInliningTime: number | null;
  jitOptimizationCount: Int8 | null;
  jitOptimizationTime: number | null;
  jitEmissionCount: Int8 | null;
  jitEmissionTime: number | null;
}

export interface ExtensionsPgStatStatementsInfo {
  dealloc: Int8 | null;
  statsReset: Timestamp | null;
}

export interface IncIncident {
  id: Generated<string>;
  tenantId: string;
  todoId: string;
  topicId: string;
  createdByResidentId: string;
  createdAt: Generated<Timestamp>;
  name: string;
  description: string | null;
  identifier: string | null;
  status: Generated<IncIncidentStatus>;
  tags: Generated<string[]>;
  isTemplate: Generated<boolean>;
}

export interface IncIncResident {
  residentId: string;
  tenantId: string;
  displayName: string;
}

export interface IncIncTenant {
  tenantId: string;
  name: string;
}

export interface MsgMessage {
  id: Generated<string>;
  tenantId: string;
  createdAt: Generated<Timestamp>;
  status: Generated<MsgMessageStatus>;
  topicId: string;
  content: string;
  postedByMsgResidentId: string;
  tags: Generated<string[]>;
}

export interface MsgMsgResident {
  id: string;
  tenantId: string;
  displayName: string;
}

export interface MsgMsgTenant {
  tenantId: string;
  name: string;
}

export interface MsgSubscriber {
  id: Generated<string>;
  tenantId: string;
  createdAt: Generated<Timestamp>;
  status: Generated<MsgSubscriberStatus>;
  topicId: string;
  msgResidentId: string;
  lastRead: Generated<Timestamp>;
}

export interface MsgTopic {
  id: Generated<string>;
  tenantId: string;
  createdAt: Generated<Timestamp>;
  name: string;
  identifier: string | null;
  tags: Generated<string[]>;
  status: Generated<MsgTopicStatus>;
}

export interface NetHttpRequestQueue {
  id: Generated<Int8>;
  method: string;
  url: string;
  headers: Json;
  body: Buffer | null;
  timeoutMilliseconds: number;
}

export interface NetHttpResponse {
  id: Int8 | null;
  statusCode: number | null;
  contentType: string | null;
  headers: Json | null;
  content: string | null;
  timedOut: boolean | null;
  errorMsg: string | null;
  created: Generated<Timestamp>;
}

export interface PgsodiumDecryptedKey {
  id: string | null;
  status: PgsodiumKeyStatus | null;
  created: Timestamp | null;
  expires: Timestamp | null;
  keyType: PgsodiumKeyType | null;
  keyId: Int8 | null;
  keyContext: Buffer | null;
  name: string | null;
  associatedData: string | null;
  rawKey: Buffer | null;
  decryptedRawKey: Buffer | null;
  rawKeyNonce: Buffer | null;
  parentKey: string | null;
  comment: string | null;
}

export interface PgsodiumKey {
  id: Generated<string>;
  status: Generated<PgsodiumKeyStatus | null>;
  created: Generated<Timestamp>;
  expires: Timestamp | null;
  keyType: PgsodiumKeyType | null;
  keyId: Generated<Int8 | null>;
  keyContext: Generated<Buffer | null>;
  name: string | null;
  associatedData: Generated<string | null>;
  rawKey: Buffer | null;
  rawKeyNonce: Buffer | null;
  parentKey: string | null;
  comment: string | null;
  userData: string | null;
}

export interface PgsodiumMaskColumns {
  attname: string | null;
  attrelid: number | null;
  keyId: string | null;
  keyIdColumn: string | null;
  associatedColumns: string | null;
  nonceColumn: string | null;
  formatType: string | null;
}

export interface PgsodiumMaskingRule {
  attrelid: number | null;
  attnum: number | null;
  relnamespace: string | null;
  relname: string | null;
  attname: string | null;
  formatType: string | null;
  colDescription: string | null;
  keyIdColumn: string | null;
  keyId: string | null;
  associatedColumns: string | null;
  nonceColumn: string | null;
  viewName: string | null;
  priority: number | null;
  securityInvoker: boolean | null;
}

export interface PgsodiumValidKey {
  id: string | null;
  name: string | null;
  status: PgsodiumKeyStatus | null;
  keyType: PgsodiumKeyType | null;
  keyId: Int8 | null;
  keyContext: Buffer | null;
  created: Timestamp | null;
  expires: Timestamp | null;
  associatedData: string | null;
}

export interface StorageBuckets {
  id: string;
  name: string;
  owner: string | null;
  createdAt: Generated<Timestamp | null>;
  updatedAt: Generated<Timestamp | null>;
  public: Generated<boolean | null>;
  avifAutodetection: Generated<boolean | null>;
  fileSizeLimit: Int8 | null;
  allowedMimeTypes: string[] | null;
}

export interface StorageMigrations {
  id: number;
  name: string;
  hash: string;
  executedAt: Generated<Timestamp | null>;
}

export interface StorageObjects {
  id: Generated<string>;
  bucketId: string | null;
  name: string | null;
  owner: string | null;
  createdAt: Generated<Timestamp | null>;
  updatedAt: Generated<Timestamp | null>;
  lastAccessedAt: Generated<Timestamp | null>;
  metadata: Json | null;
  pathTokens: Generated<string[] | null>;
  version: string | null;
}

export interface SupabaseFunctionsHooks {
  id: Generated<Int8>;
  hookTableId: number;
  hookName: string;
  createdAt: Generated<Timestamp>;
  requestId: Int8 | null;
}

export interface SupabaseFunctionsMigrations {
  version: string;
  insertedAt: Generated<Timestamp>;
}

export interface SupabaseMigrationsSchemaMigrations {
  version: string;
  statements: string[] | null;
  name: string | null;
}

export interface TodoTodo {
  id: Generated<string>;
  parentTodoId: string | null;
  tenantId: string;
  residentId: string;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
  name: string;
  description: string | null;
  status: Generated<TodoTodoStatus>;
  type: Generated<TodoTodoType>;
  ordinal: number;
  pinned: Generated<boolean>;
  tags: Generated<string[]>;
  isTemplate: Generated<boolean>;
}

export interface TodoTodoResident {
  residentId: string;
  tenantId: string;
  displayName: string;
}

export interface TodoTodoTenant {
  tenantId: string;
  name: string;
}

export interface VaultDecryptedSecrets {
  id: string | null;
  name: string | null;
  description: string | null;
  secret: string | null;
  decryptedSecret: string | null;
  keyId: string | null;
  nonce: Buffer | null;
  createdAt: Timestamp | null;
  updatedAt: Timestamp | null;
}

export interface VaultSecrets {
  id: Generated<string>;
  name: string | null;
  description: Generated<string>;
  secret: string;
  keyId: Generated<string | null>;
  nonce: Generated<Buffer | null>;
  createdAt: Generated<Timestamp>;
  updatedAt: Generated<Timestamp>;
}

export interface DB {
  "_Realtime.extensions": _RealtimeExtensions;
  "_Realtime.schemaMigrations": _RealtimeSchemaMigrations;
  "_Realtime.tenants": _RealtimeTenants;
  "app.application": AppApplication;
  "app.appSettings": AppAppSettings;
  "app.license": AppLicense;
  "app.licensePack": AppLicensePack;
  "app.licensePackLicenseType": AppLicensePackLicenseType;
  "app.licenseType": AppLicenseType;
  "app.licenseTypePermission": AppLicenseTypePermission;
  "app.permission": AppPermission;
  "app.profile": AppProfile;
  "app.resident": AppResident;
  "app.tenant": AppTenant;
  "app.tenantSubscription": AppTenantSubscription;
  "auth.auditLogEntries": AuthAuditLogEntries;
  "auth.flowState": AuthFlowState;
  "auth.identities": AuthIdentities;
  "auth.instances": AuthInstances;
  "auth.mfaAmrClaims": AuthMfaAmrClaims;
  "auth.mfaChallenges": AuthMfaChallenges;
  "auth.mfaFactors": AuthMfaFactors;
  "auth.refreshTokens": AuthRefreshTokens;
  "auth.samlProviders": AuthSamlProviders;
  "auth.samlRelayStates": AuthSamlRelayStates;
  "auth.schemaMigrations": AuthSchemaMigrations;
  "auth.sessions": AuthSessions;
  "auth.ssoDomains": AuthSsoDomains;
  "auth.ssoProviders": AuthSsoProviders;
  "auth.users": AuthUsers;
  "extensions.pgStatStatements": ExtensionsPgStatStatements;
  "extensions.pgStatStatementsInfo": ExtensionsPgStatStatementsInfo;
  "inc.incident": IncIncident;
  "inc.incResident": IncIncResident;
  "inc.incTenant": IncIncTenant;
  "msg.message": MsgMessage;
  "msg.msgResident": MsgMsgResident;
  "msg.msgTenant": MsgMsgTenant;
  "msg.subscriber": MsgSubscriber;
  "msg.topic": MsgTopic;
  "net.httpRequestQueue": NetHttpRequestQueue;
  "net.HttpResponse": NetHttpResponse;
  "pgsodium.decryptedKey": PgsodiumDecryptedKey;
  "pgsodium.key": PgsodiumKey;
  "pgsodium.maskColumns": PgsodiumMaskColumns;
  "pgsodium.maskingRule": PgsodiumMaskingRule;
  "pgsodium.validKey": PgsodiumValidKey;
  "storage.buckets": StorageBuckets;
  "storage.migrations": StorageMigrations;
  "storage.objects": StorageObjects;
  "supabaseFunctions.hooks": SupabaseFunctionsHooks;
  "supabaseFunctions.migrations": SupabaseFunctionsMigrations;
  "supabaseMigrations.schemaMigrations": SupabaseMigrationsSchemaMigrations;
  "todo.todo": TodoTodo;
  "todo.todoResident": TodoTodoResident;
  "todo.todoTenant": TodoTodoTenant;
  "vault.decryptedSecrets": VaultDecryptedSecrets;
  "vault.secrets": VaultSecrets;
}
