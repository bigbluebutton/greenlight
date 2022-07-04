import React from 'react';
import PropTypes from 'prop-types';
import { Badge, Dropdown } from 'react-bootstrap';
import { DotsVerticalIcon, PencilAltIcon, TrashIcon } from '@heroicons/react/outline';

export default function RoleRow({ role }) {
  return (
    <tr className="align-middle">
      <td>
        <Badge pill ref={(el) => el && el.style.setProperty('background-color', role.color, 'important')}>
          {role.name}
        </Badge>
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={DotsVerticalIcon} />
          <Dropdown.Menu>
            <Dropdown.Item><PencilAltIcon className="hi-s" /> Edit</Dropdown.Item>
            <Dropdown.Item> <TrashIcon className="hi-s" /> Delete</Dropdown.Item>
          </Dropdown.Menu>
        </Dropdown>
      </td>
    </tr>
  );
}

RoleRow.propTypes = {
  role: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
  }).isRequired,
};
