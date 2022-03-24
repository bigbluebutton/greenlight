import React from "react";
import { Spinner as BootstrapSpinner } from "react-bootstrap";
 
 export const Spinner = (props) => (
    <BootstrapSpinner
    as="span"
    animation="grow"
    size="sm"
    role="status"
    aria-hidden="true"
    {...props}
   />
 ) 