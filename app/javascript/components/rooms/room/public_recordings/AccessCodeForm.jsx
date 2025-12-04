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
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import { Form, Button, Stack } from 'react-bootstrap';
import ButtonLink from '../../../shared_components/utilities/ButtonLink';
import UserBoardIcon from '../../UserBoardIcon';

export default function AccessCodeForm({ onAccessCodeSubmit, error, friendlyId }) {
  const { t } = useTranslation();
  const [accessCode, setAccessCode] = useState('');
  const [validated] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [emptyCodeError, setEmptyCodeError] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Reset error states
    setEmptyCodeError(false);
    
    // Check for empty access code first
    if (!accessCode?.trim()) {
      setEmptyCodeError(true);
      return;
    }
    
    setIsSubmitting(true);
    
    // Call the submit handler and reset submission state when complete
    Promise.resolve(onAccessCodeSubmit(accessCode))
      .finally(() => {
        setIsSubmitting(false);
      });
  };

  return (
    <div className="text-center p-4">
      <h2>{t('recording.access_code_required')}</h2>
      <p className="mb-4">{t('recording.enter_access_code_description')}</p>
      
      <Form noValidate validated={validated} onSubmit={handleSubmit}>
        <Form.Group className="mb-3 d-flex justify-content-center">
          <div className="position-relative w-50">
            <Form.Control
              type="text"
              placeholder={t('recording.access_code_placeholder')}
              value={accessCode}
              onChange={(e) => {
                setAccessCode(e.target.value);
                if (e.target.value.trim()) {
                  setEmptyCodeError(false);
                }
              }}
              required
              autoFocus
              isInvalid={error || emptyCodeError}
              className={`${(error || emptyCodeError) ? 'border-danger' : ''} text-center`}
            />
            <Form.Control.Feedback type="invalid" className="text-center">
              {emptyCodeError && t('room.settings.access_code_required')}
              {error && !emptyCodeError && t('recording.invalid_access_code')}
            </Form.Control.Feedback>
          </div>
        </Form.Group>
        
        <Stack direction="horizontal" gap={2} className="justify-content-center">
          <ButtonLink
            variant="brand-outline"
            className="my-0 py-2"
            to={`/rooms/${friendlyId}/join`}
          >
            <span><UserBoardIcon className="hi-s text-brand cursor-pointer" /> {t('join_session')} </span>
          </ButtonLink>
          <Button 
            variant="brand" 
            type="submit" 
            disabled={isSubmitting}
          >
            {isSubmitting ? t('common.submitting') ?? 'Submitting...' : t('recording.submit_access_code')}
          </Button>
        </Stack>
      </Form>
    </div>
  );
}

AccessCodeForm.propTypes = {
  onAccessCodeSubmit: PropTypes.func.isRequired,
  error: PropTypes.bool,
  friendlyId: PropTypes.string.isRequired,
};

AccessCodeForm.defaultProps = {
  error: false,
};
