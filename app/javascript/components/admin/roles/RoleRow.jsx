// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
