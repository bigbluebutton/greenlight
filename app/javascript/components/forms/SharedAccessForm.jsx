/* eslint-disable react/jsx-props-no-spreading */

import React, { useState } from 'react';
import {
  Button, Col, Form, Row, Stack,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useParams } from 'react-router-dom';
import useShareAccess from '../../hooks/mutations/shared_accesses/useShareAccess';
import Avatar from '../users/Avatar';
import SearchBar from '../shared/SearchBar';
import useShareableUsers from '../../hooks/queries/shared_accesses/useShareableUsers';
import Spinner from '../shared/stylings/Spinner';

export default function SharedAccessForm({ handleClose }) {
  const { register, handleSubmit } = useForm();
  const { friendlyId } = useParams();
  const { onSubmit } = useShareAccess({ friendlyId, closeModal: handleClose });
  const { isLoading, data: users } = useShareableUsers(friendlyId);
  const [search, setSearch] = useState('');

  if (isLoading) return <Spinner />;

  return (
    <>
      <SearchBar id="shared-users-modal-search" setSearch={setSearch} />
      <Form onSubmit={handleSubmit(onSubmit)}>
        <Row className="border-bottom pt-3 pb-2">
          <Col>
            <span className="text-muted small"> Name </span>
          </Col>
          <Col>
            <span className="text-muted small"> Email address </span>
          </Col>
        </Row>
        {
          users?.filter((user) => {
            if (user.name.toLowerCase().includes(search.toLowerCase())) {
              return user;
            }
            return false;
          }).map((user) => (
            <Row className="border-bottom py-3" key={user.id}>
              <Col>
                <Stack direction="horizontal">
                  <Form.Check
                    type="checkbox"
                    value={user.id}
                    aria-label="tbd"
                    className="pe-3"
                    {...register('shared_users')}
                  />
                  <Avatar avatar={user.avatar} radius={40} />
                  <h6 className="text-primary mb-0 ps-3"> { user.name } </h6>
                </Stack>
              </Col>
              <Col className="my-auto">
                <span className="text-muted"> { user.email } </span>
              </Col>
            </Row>
          ))
        }
        <Stack className="mt-3" direction="horizontal" gap={1}>
          <Button variant="primary-light" className="ms-auto" onClick={handleClose}>
            Close
          </Button>
          <Button variant="primary" type="submit">
            Share
          </Button>
        </Stack>
      </Form>
    </>
  );
}

SharedAccessForm.propTypes = {
  handleClose: PropTypes.func,
};

SharedAccessForm.defaultProps = {
  handleClose: () => { },
};
