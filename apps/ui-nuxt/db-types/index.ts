import * as app from './db.app'
import * as todo from './db.todo'
import * as msg from './db.msg'
import * as inc from './db.inc'

// THIS SHOULD BE COMING FROM UI NUXT LABS, BUT NOT SURE HOW RIGHT NOW
export interface IUSelectOption {
  name: string
  value: string
  label: string
}

declare global {
  type USelectOption = IUSelectOption
}

// APP
export interface IApplication extends app.AppApplication {
  licenseTypes?: ILicenseType[]
}

export interface IResident extends app.AppResident {
  profile?: IProfile
  licenses?: ILicense[]
}

export interface IProfile extends app.AppProfile {
  residents?: IResident[]
}

export interface ITenant extends app.AppTenant {
  residents?: IResident[]
  tenantSubscriptions?: ITenantSubscription[]
}

export interface ITenantSubscription extends app.AppTenantSubscription {
  tenant?: ITenant
  licenses?: ILicense[]
  licensePack: ILicensePack
}

export interface ILicenseTypePermission extends app.AppLicenseTypePermission {

}

export interface ILicensePack extends app.AppLicensePack {
  licensePackLicenseTypes?: ILicensePackLicenseType[]
  tenantSubscriptions: {
    totalCount: number
  }
}

export interface ILicenseType extends app.AppLicenseType {
licenseType: any
[x: string]: any
  permissions: ILicenseTypePermission[]
  licenses: {
    totalCount: number
  }
}

export interface ILicensePackLicenseType extends app.AppLicensePackLicenseType {
  licenseType?: ILicenseType
  licensePack?: ILicensePack
}

export interface ILicense extends app.AppLicense {
  resident?: IResident
}

export interface INewTenantInfo {
  name: string
  email: string
}

declare global {
  type Application = IApplication
  type Resident = IResident
  type Profile = IProfile
  type Tenant = ITenant
  type TenantSubscription = ITenantSubscription
  type LicenseTypePermission = ILicenseTypePermission
  type LicensePack = ILicensePack
  type LicenseType = ILicenseType
  type LicensePackLicenseType = ILicensePackLicenseType
  type License = ILicense
  type NewTenantInfo = INewTenantInfo
}

// TODO
export interface ITodoResident extends todo.TodoTodoResident {

}

export interface ITodo extends todo.TodoTodo {
  owner?: ITodoResident
  children?: Todo[]
  hiddenChildren?: {
    totalCount: number
  }
}

declare global {
  type Todo = ITodo
}

// MSG
export interface ITopic extends msg.MsgTopic {}
export interface IMessage extends msg.MsgMessage {}
export interface ISubscriber extends msg.MsgSubscriber {}

declare global {
  type Topic = ITopic
  type Message = IMessage
  type Subscriber = ISubscriber
}

// INC
export interface IIncident extends inc.IncIncident {}

declare global {
  type Incident = IIncident
}