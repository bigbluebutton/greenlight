import React from 'react';
import {Badge} from "react-bootstrap";

export default function RolePill({ role }) {
  const { name, color } = role

  return (
    <Badge pill ref={(el) => el && el.style.setProperty('background-color', color, 'important')}>
      {name}
    </Badge>
  );
}
