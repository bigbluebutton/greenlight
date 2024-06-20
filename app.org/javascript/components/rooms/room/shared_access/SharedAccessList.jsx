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

import React, { useState } from 'react';
import {
  Button, Card, Col, Row, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { TrashIcon } from '@heroicons/react/24/outline';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Modal from '../../../shared_components/modals/Modal';
import SharedAccessForm from './forms/SharedAccessForm';
import Avatar from '../../../users/user/Avatar';
import useDeleteSharedAccess from '../../../../hooks/mutations/shared_accesses/useDeleteSharedAccess';
import SearchBar from '../../../shared_components/search/SearchBar';

export default function SharedAccessList({ users }) {
  const { t } = useTranslation();
  const [searchInput, setSearchInput] = useState('');
  const { friendlyId } = useParams();
  const { handleDeleteSharedAccess } = useDeleteSharedAccess(friendlyId);

  return (
    <div id="shared-access-list">
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} className="w-100" />
        </div>
        <Modal
          modalButton={<Button variant="brand-outline" className="ms-auto">{ t('room.shared_access.add_share_access') }</Button>}
          title={t('room.shared_access.share_room_access')}
          body={<SharedAccessForm />}
          size="lg"
          id="shared-access-modal"
        />
      </Stack>

      <Card className="border-0 card-shadow mt-4">
        <Card.Body>
          <Row className="border-bottom pb-2">
            <Col>
              <span className="text-muted small">{ t('user.name') }</span>
            </Col>
          </Row>
          {
            users?.filter((user) => {
              if (user.name.toLowerCase()
                .includes(searchInput.toLowerCase())) {
                return user;
              }
              return false;
            })
              .map((user) => (
                <Row className="border-bottom py-3" key={user.id}>
                  <Col>
                    <Stack direction="horizontal">
                      <Avatar avatar={user.avatar} size="small" />
                      <h6 className="text-brand mb-0 ps-3"> {user.name} </h6>
                    </Stack>
                  </Col>
                  <Col className="my-auto">
                    <Button
                      variant="icon"
                      className="float-end pe-2"
                      onClick={() => handleDeleteSharedAccess({ user_id: user.id })}
                    >
                      <TrashIcon className="hi-s" />
                    </Button>
                  </Col>
                </Row>
              ))
          }
        </Card.Body>
      </Card>
    </div>
  );
}

SharedAccessList.propTypes = {
  users: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    filter: PropTypes.func,
  })).isRequired,
};
