import React from "react";
import { Link } from "react-router-dom";
import Button from 'react-bootstrap/Button';

export default () => (
  <div>
    <p>This is a test</p>
    <Link to="/othertest">OtherTest</Link>
    <Button variant="primary" className="mr-1">
      Primary
    </Button>
  </div>
);
