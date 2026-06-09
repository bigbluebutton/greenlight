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
import {
  Form, Stack, Table,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Avatar from '../../../../users/user/Avatar';

export default function UserSearchTable({
  users, searchInput, inputType, inputName, isChecked, onChange,
}) {
  const { t } = useTranslation();

  if (inputType === 'radio' && !inputName) {
    console.error('UserSearchTable: inputName is required when inputType is "radio"');
  }

  return (
    <div className="table-scrollbar-wrapper">
      <Table hover responsive className="text-secondary my-3">
        <thead>
          <tr className="text-muted small">
            <th className="fw-normal">{ t('user.name') }</th>
          </tr>
        </thead>
        <tbody className="border-top-0">
          {
            (() => {
              if (searchInput?.length >= 3 && users?.length) {
                return (
                  users.map((user) => (
                    <tr
                      key={user.id}
                      className="align-middle"
                    >
                      <td>
                        <Stack direction="horizontal" className="py-2">
                          <Form.Label className="w-100 mb-0 text-brand">
                            <Form.Check
                              id={`${user.id}-${inputType}`}
                              type={inputType}
                              name={inputName}
                              value={user.id}
                              className="d-inline-block"
                              checked={isChecked(user.id)}
                              onChange={() => onChange(user.id)}
                            />
                            <Avatar avatar={user.avatar} size="small" className="d-inline-block px-3" />
                            {user.name}
                          </Form.Label>
                        </Stack>
                      </td>
                    </tr>
                  )));
              } if (searchInput?.length >= 3) {
                return (<tr className="fw-bold"><td>{ t('user.no_user_found') }</td></tr>);
              }
              return (<tr className="fw-bold"><td colSpan="2">{ t('user.type_three_characters') }</td></tr>);
            })()
          }
        </tbody>
      </Table>
    </div>
  );
}

UserSearchTable.propTypes = {
  users: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    avatar: PropTypes.string,
  })),
  searchInput: PropTypes.string,
  inputType: PropTypes.oneOf(['checkbox', 'radio']).isRequired,
  inputName: PropTypes.string,
  isChecked: PropTypes.func.isRequired,
  onChange: PropTypes.func.isRequired,
};

UserSearchTable.defaultProps = {
  users: [],
  searchInput: undefined,
  inputName: undefined,
};
