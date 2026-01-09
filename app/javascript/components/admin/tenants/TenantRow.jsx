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

import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import { TrashIcon } from '@heroicons/react/24/outline';
import Modal from '../../shared_components/modals/Modal';
import DeleteTenantForm from './forms/DeleteTenantForm';

export default function TenantRow({ tenant }) {
  return (
    <tr className="align-middle border border-2">
      <td className="py-4 border-0">
        <strong> {tenant?.name} </strong>
      </td>
      <td className="py-4 border-0">
        {tenant?.client_secret}
      </td>
      <td className="py-4 border-0">
        {tenant?.region}
      </td>
      <td className="border-start-0 text-end tenants-icons">
        <Modal
          modalButton={<Button variant="icon"><TrashIcon className="hi-s" /></Button>}
          body={(
            <DeleteTenantForm
              tenantId={tenant?.id}
            />
          )}
        />
      </td>
    </tr>
  );
}

TenantRow.propTypes = {
  tenant: PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
    client_secret: PropTypes.string,
    region: PropTypes.string,
  }).isRequired,
};
