/* eslint-disable react/jsx-props-no-spreading */

import React, { useState } from 'react';
import {
  Button, Form, Stack, Table,
} from 'react-bootstrap';
import { useForm } from 'react-hook-form';
import PropTypes from 'prop-types';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import useShareAccess from '../../../../../hooks/mutations/shared_accesses/useShareAccess';
import Avatar from '../../../../users/user/Avatar';
import SearchBarQuery from '../../../../shared_components/search/SearchBarQuery';
import useShareableUsers from '../../../../../hooks/queries/shared_accesses/useShareableUsers';

export default function SharedAccessForm({ handleClose }) {
  const { t } = useTranslation();
  const { register, handleSubmit } = useForm();
  const { friendlyId } = useParams();
  const createSharedUser = useShareAccess({ friendlyId, closeModal: handleClose });
  const [input, setInput] = useState();

  // launch a query only if there is more than three characters in the search box
  const isThreeCharacters = input?.length >= 3;
  const { data: shareableUsers } = useShareableUsers(friendlyId, input, isThreeCharacters);

  return (
    <div id="shared-access-form">
      <SearchBarQuery setInput={setInput} />
      <Form onSubmit={handleSubmit(createSharedUser.mutate)}>
        <div className="table-scrollbar-wrapper">
          <Table hover className="text-secondary my-3">
            <thead>
              <tr className="text-muted small">
                <th className="fw-normal w-50">{ t('user.name') }</th>
                <th className="fw-normal w-50">{ t('user.email_address') }</th>
              </tr>
            </thead>
            <tbody className="border-top-0">
              {
                (() => {
                  if (isThreeCharacters && shareableUsers?.length) {
                    return (
                      shareableUsers.map((user) => (
                        <tr key={user.id} className="align-middle">
                          <td>
                            <Stack direction="horizontal" className="py-2">
                              <Form.Check
                                type="checkbox"
                                value={user.id}
                                className="pe-3"
                                {...register('shared_users')}
                              />
                              <Avatar avatar={user.avatar} radius={40} />
                              <h6 className="text-brand mb-0 ps-3"> {user.name} </h6>
                            </Stack>
                          </td>
                          <td>
                            <span className="text-muted"> {user.email} </span>
                          </td>
                        </tr>
                      )));
                  } if (isThreeCharacters && !shareableUsers?.length) {
                    return (<tr className="fw-bold"><td>{ t('user.no_user_found') }</td><td /></tr>);
                  }
                  return (<tr className="fw-bold"><td colSpan="2">{ t('user.type_three_characters') }</td></tr>);
                })()
              }
            </tbody>
          </Table>
        </div>
        <Stack className="mt-3" direction="horizontal" gap={1}>
          <Button variant="neutral" className="ms-auto" onClick={handleClose}>
            { t('close') }
          </Button>
          <Button variant="brand" type="submit">
            { t('share') }
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
