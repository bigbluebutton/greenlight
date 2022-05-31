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
import SearchBarQuery from '../shared/SearchBarQuery';
import useShareableUsers from '../../hooks/queries/shared_accesses/useShareableUsers';

export default function SharedAccessForm({ handleClose }) {
  const { register, handleSubmit } = useForm();
  const { friendlyId } = useParams();
  const { onSubmit } = useShareAccess({ friendlyId, closeModal: handleClose });
  const [input, setInput] = useState();
  const [shareableUsers, setShareableUsers] = useState();
  useShareableUsers(friendlyId, input, setShareableUsers);

  return (
    <div id="shared-access-form">
      <SearchBarQuery setInput={setInput} />
      <Form onSubmit={handleSubmit(onSubmit)}>
        <Row className="border-bottom pt-3 pb-2">
          <Col>
            <span className="text-muted small"> Name </span>
          </Col>
          <Col>
            <span className="text-muted small"> Email address </span>
          </Col>
        </Row>
        {shareableUsers?.length
          ? (
            shareableUsers.map((user) => (
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
          )
          : (
            <p className="fw-bold"> No user found! </p>
          )}
        <Stack className="mt-3" direction="horizontal" gap={1}>
          <Button variant="primary-light" className="ms-auto" onClick={handleClose}>
            Close
          </Button>
          <Button variant="primary" type="submit">
            Share
          </Button>
        </Stack>
      </Form>
    </div>
  );
}

SharedAccessForm.propTypes = {
  handleClose: PropTypes.func,
};

SharedAccessForm.defaultProps = {
  handleClose: () => { },
};
