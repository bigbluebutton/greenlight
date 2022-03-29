import React, { ReactElement } from "react";
import { Form as BootStrapForm, FormControlProps, FormGroupProps, FormLabelProps, FormProps } from "react-bootstrap";
import { FieldError, useFormContext } from "react-hook-form";
import { SignupFormInputs, SignupFormField } from "../../helpers/forms/SignupFormHelpers";

type Props = FormGroupProps & FormLabelProps & FormControlProps & { field: SignupFormField }

const FormControl: React.FC<Props> = ({field,...props}): ReactElement => {
   const { register , formState:{errors} } = useFormContext<SignupFormInputs>()
   const { hookForm } = field
   const { id, validations } = hookForm
   const error: FieldError = errors[id]
    return (
        <BootStrapForm.Group controlId={field.controlId}>
          <BootStrapForm.Label>
             {field.label}
          </BootStrapForm.Label>
          <BootStrapForm.Control {...props} placeholder={field.placeHolder} isInvalid={!!error} {...register(id, validations)}/>
          {
              error &&
              (
                ( error.types &&
                  Object.keys(error.types).map(
                      key => <BootStrapForm.Control.Feedback key={key} type="invalid">{error.types[key]}</BootStrapForm.Control.Feedback>
                  ) 
                )
                || <BootStrapForm.Control.Feedback type="invalid">{error.message}</BootStrapForm.Control.Feedback>
              )

          }
        </BootStrapForm.Group>
    )
}

export default FormControl