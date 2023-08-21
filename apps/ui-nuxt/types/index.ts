import * as app from './db.app'
import * as todo from './db.todo'
// import * as msg from './db.msg'
// import * as inc from './db.inc'

export interface Application extends app.AppApplication {
  licenseTypes?: app.AppLicenseType[]
}

export interface Resident extends app.AppResident {

}

export interface TodoResident extends todo.TodoTodoResident {

}

export interface Todo extends todo.TodoTodo {
  owner?: TodoResident
  children?: Todo[]
  hiddenChildren?: {
    totalCount: number
  }
}

