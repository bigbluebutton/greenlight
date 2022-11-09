import React, { useCallback } from 'react';
import PropTypes from 'prop-types';
import { useNavigate } from 'react-router-dom';
import { ShieldCheckIcon } from '@heroicons/react/20/solid';
import { Stack } from 'react-bootstrap';
import { LockClosedIcon } from '@heroicons/react/24/outline';

export default function RoleRow({ role }) {
  const navigate = useNavigate();
  const handleClick = useCallback(() => { navigate(`edit/${role.id}`); }, [role.id]);

  return (
    <tr className="align-middle border border-2 cursor-pointer" onClick={handleClick}>
      <td className="py-4">
        <Stack direction="horizontal">
          <ShieldCheckIcon className="hi-s" ref={(el) => el && el.style.setProperty('color', role?.color, 'important')} />
          {
            (role?.name === 'Administrator' || role?.name === 'User' || role?.name === 'Guest')
            && <LockClosedIcon className="hi-xs text-muted" />
          }
          <strong className="ms-2"> {role?.name} </strong>
        </Stack>
      </td>
    </tr>
  );
}

RoleRow.propTypes = {
  role: PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    color: PropTypes.string.isRequired,
  }).isRequired,
};
