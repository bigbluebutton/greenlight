/* eslint-disable react/jsx-props-no-spreading */

import React, { useState } from 'react';
import {
  Button, Form, Stack, Table,
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
        <Table hover className="text-secondary my-3">
          <thead>
            <tr className="text-muted small">
              <th className="fw-normal w-50">Name</th>
              <th className="fw-normal w-50">Email address</th>
            </tr>
          </thead>
          <tbody className="border-top-0">
            {shareableUsers?.length
              ? (
                shareableUsers.map((user) => (
                  <tr key={user.id} className="align-middle">
                    <td>
                      <Stack direction="horizontal" className="py-2">
                        <Form.Check
                          type="checkbox"
                          value={user.id}
                          aria-label="tbd"
                          className="pe-3"
                          {...register('shared_users')}
                        />
                        <Avatar avatar={user.avatar} radius={40} />
                        <h6 className="text-brand mb-0 ps-3"> { user.name } </h6>
                      </Stack>
                    </td>
                    <td>
                      <span className="text-muted"> { user.email } </span>
                    </td>
                  </tr>
                ))
              )
              : (
                <tr className="fw-bold"><td>No user found!</td><td /></tr>
              )}
          </tbody>
        </Table>
        <Stack className="mt-3" direction="horizontal" gap={1}>
          <Button variant="brand-backward" className="ms-auto" onClick={handleClose}>
            Close
          </Button>
          <Button variant="brand" type="submit">
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
