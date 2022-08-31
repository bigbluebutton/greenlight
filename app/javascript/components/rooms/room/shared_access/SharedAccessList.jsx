import React, { useState } from 'react';
import {
  Button, Card, Col, Row, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import { TrashIcon } from '@heroicons/react/outline';
import { useParams } from 'react-router-dom';
import Modal from '../../../shared_components/modals/Modal';
import SharedAccessForm from './forms/SharedAccessForm';
import Avatar from '../../../users/user/Avatar';
import SearchBar from '../../../shared_components/search/SearchBar';
import useDeleteSharedAccess from '../../../../hooks/mutations/shared_accesses/useDeleteSharedAccess';
import Spinner from '../../../shared_components/utilities/Spinner';

export default function SharedAccessList({ users, isLoading }) {
  const [search, setSearch] = useState('');
  const { friendlyId } = useParams();
  const { handleDeleteSharedAccess } = useDeleteSharedAccess(friendlyId);

  if (isLoading) return <Spinner />;

  return (
    <div id="shared-access-list">
      <Stack direction="horizontal" className="w-100 mt-5">
        <div>
          <SearchBar setSearch={setSearch} className="w-100" />
        </div>
        <Modal
          modalButton={<Button variant="brand-backward" className="ms-auto">+ Share Access</Button>}
          title="Share Room Access"
          body={<SharedAccessForm />}
          size="lg"
          id="shared-access-modal"
        />
      </Stack>

      <Card className="border-0 shadow-sm mt-4">
        <Card.Body>
          <Row className="border-bottom pb-2">
            <Col>
              <span className="text-muted small"> Name </span>
            </Col>
            <Col>
              <span className="text-muted small"> Email address </span>
            </Col>
          </Row>
          {
            users?.filter((user) => {
              if (user.name.toLowerCase()
                .includes(search.toLowerCase())) {
                return user;
              }
              return false;
            })
              .map((user) => (
                <Row className="border-bottom py-3" key={user.id}>
                  <Col>
                    <Stack direction="horizontal">
                      <Avatar avatar={user.avatar} radius={40} />
                      <h6 className="text-brand mb-0 ps-3"> {user.name} </h6>
                    </Stack>
                  </Col>
                  <Col className="my-auto">
                    <span className="text-muted"> {user.email} </span>
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
  isLoading: PropTypes.bool.isRequired,
};
