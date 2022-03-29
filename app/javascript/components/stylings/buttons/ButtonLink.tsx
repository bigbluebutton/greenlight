import { useNavigate,To } from "react-router";
import {Button, ButtonProps} from "react-bootstrap";
import React, { ReactElement, useCallback } from "react";

const ButtonLink: React.FC<ButtonProps & {to: To} > = ({to,...rest}): ReactElement => {
  const navigate = useNavigate() 
  const handleClick = useCallback( () => { navigate(to) }, [to] )

  return (
    <Button 
      {...rest}
      onClick={handleClick}
    />
  )
}

export default ButtonLink