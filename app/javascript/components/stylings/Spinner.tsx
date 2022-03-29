import React, { ReactElement } from "react";
import { Spinner as BootstrapSpinner, SpinnerProps } from "react-bootstrap";
 
 const Spinner: React.FC<SpinnerProps> = (props): ReactElement => (
    <BootstrapSpinner
    as="span"
    size="sm"
    role="status"
    aria-hidden="true"
    {...props}
   />
 ) 

 export default Spinner