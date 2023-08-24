import type { ColumnType } from "kysely";

export type Generated<T> = T extends ColumnType<infer S, infer I, infer U>
  ? ColumnType<S, I | undefined, U>
  : ColumnType<T, T | undefined, T>;

export type IncIncidentStatus = "closed" | "deleted" | "open" | "pending";

export type Timestamp = ColumnType<Date, Date | string, Date | string>;

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

export interface IncLocation {
  id: Generated<string>;
  tenantId: string;
  incidentId: string;
  name: string | null;
  address1: string | null;
  address2: string | null;
  city: string | null;
  state: string | null;
  postalcode: string | null;
  country: string | null;
  lat: string | null;
  lon: string | null;
}

export interface DB {
  "inc.incident": IncIncident;
  "inc.incResident": IncIncResident;
  "inc.incTenant": IncIncTenant;
  "inc.location": IncLocation;
}
