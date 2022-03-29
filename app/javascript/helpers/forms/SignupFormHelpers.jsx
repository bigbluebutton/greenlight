export const signupFormConfig = {
        mode: 'onChange',
        criteriaMode: 'all',
        defaultValues: {
          'name': '',
          'email': '',
          'password': '',
          'password_confirmation': ''
        }
}

function postData(url,data){
    return fetch(url,
    {
        method: 'POST', // *GET, POST, PUT, DELETE, etc.
        mode: 'same-origin', // no-cors, *cors, same-origin
        cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
        credentials: 'same-origin', // include, *same-origin, omit
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
        ,
        redirect: 'error', // manual, *follow, error
        referrerPolicy: 'no-referrer', // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
        body: JSON.stringify(data) // body data type must match "Content-Type" header
    }
  )
}

export async function signupFormOnSubmit(user_data) {
   console.log("Sending",JSON.stringify({user: user_data}))
   const response = await postData('/api/v1/users.json',{user: user_data})
   console.log(response.json()) // parses JSON response into native JavaScript objects
}

export const signupFormFields = {
    name: {
        label: 'Full Name',
        placeHolder : 'Please enter your full name',
        controlId: 'signupFormFullName',
        hookForm: {
            id: 'name',
            validations:  {
                validate: {},
                required: 'This field is required.'
              }
        }
    },
    email: {
        label: 'Email',
        placeHolder : 'Please enter your email',
        controlId: 'signupFormEmail',
        hookForm: {
            id: 'email',
            validations:  {
                validate: {},
                required: 'This field is required.',
                pattern: {
                    value: /\S+@\S+\.\S+/, //TODO: amir - chagne this or use Yup.
                    message: "Entered value does not match email format."
                  }
              }
        }
    },
    password: {
        label: 'Password',
        placeHolder : '********',
        controlId: 'signupFormPwd',
        hookForm: {
            id: 'password',
            validations:  {
                validate: {},
                required: 'This field is required.',
                minLength: {
                    value: 8,
                    message: 'Password must have at least 8 charachters.'
                },
                deps: 'password_confirmation'
              }
        }
    },
    password_confirmation: {
        label: 'Password Confirmation',
        placeHolder : '********',
        controlId: 'signupFormPwdConfirm',
        hookForm: {
            id: 'password_confirmation',
            validations:  {
                validate: {},
                deps: 'password'
              }
        }
    }
}
