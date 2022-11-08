import React, { useCallback } from 'react';
import PropTypes from 'prop-types';
import { useNavigate } from 'react-router-dom';
import RolePill from './RolePill';

export default function RoleRow({ role }) {
  const navigate = useNavigate();
  const handleClick = useCallback(() => { navigate(`edit/${role.id}`); }, [role.id]);

  return (
    <tr className="align-middle text-muted border border-2 cursor-pointer" onClick={handleClick}>
      <td className="py-4">
        <RolePill role={role} />
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
