import React, { useState } from 'react';
import {
  Button, Card, Col, Row, Stack,
} from 'react-bootstrap';
import PropTypes from 'prop-types';
import Modal from '../shared/Modal';
import SharedAccessForm from '../forms/shared_access_forms/SharedAccessForm';
import DeleteSharedAccessForm from '../forms/shared_access_forms/DeleteSharedAccessForm';
import Avatar from '../users/Avatar';
import SearchBar from '../shared/SearchBar';

export default function SharedAccessList({ users }) {
  const [search, setSearch] = useState('');

  return (
    <div id="shared-access-list" className="wide-background full-height-room">
      <Stack direction="horizontal" className="w-100 mt-5">
        <SearchBar id="shared-users-search" setSearch={setSearch} />
        <Modal
          modalButton={<Button variant="primary-reverse" className="ms-auto">+ Share Access</Button>}
          title="Share Room Access"
          body={<SharedAccessForm />}
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
                      <h6 className="text-primary mb-0 ps-3"> {user.name} </h6>
                    </Stack>
                  </Col>
                  <Col className="my-auto">
                    <span className="text-muted"> {user.email} </span>
                    <DeleteSharedAccessForm userId={user.id} />
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
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    filter: PropTypes.func,
  })).isRequired,
};
