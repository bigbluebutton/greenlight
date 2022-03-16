import React from "react";
import { Form } from "react-bootstrap";


export function FormControl({field, register , error, ...props}){

    return (
        <Form.Group controlId={field.controlId}>
          <Form.Label>
             {field.label}
          </Form.Label>
          <Form.Control {...props} placeholder={field.placeHolder}  isInvalid={error} {...register}/>
          {
              ( error?.types &&
              Object.keys(error.types).map(
                  key => (
                    <Form.Control.Feedback key={key} type="invalid">{error.types[key]}</Form.Control.Feedback>
                  )
            ) ) || (
              error && <Form.Control.Feedback type="invalid">{error.message}</Form.Control.Feedback>
            )

          }
        </Form.Group>
    )
}