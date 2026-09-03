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

/* eslint-disable consistent-return */
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import PublicRecordingsList from './PublicRecordingsList';
import AccessCodeForm from './AccessCodeForm';

export default function PublicRecordingsCard({ 
  accessCode, 
  onAccessCodeSubmit, 
  onAccessCodeError,
  accessCodeError
}) {
  const { friendlyId } = useParams();
  const [requiresAccessCode, setRequiresAccessCode] = useState(false);
  const [isValidating, setIsValidating] = useState(!!accessCode);

  const handleAccessCodeSubmit = async (code) => {
    setIsValidating(true);
    
    try {
      // Wait until the access code is submitted
      await onAccessCodeSubmit(code);
      
      // Check the access code validity immediately after the API response
      // This is more reliable than using a timeout
      const checkAccessCodeValidity = () => {
        if (requiresAccessCode) {
          // If we still need the access code, the entered code was incorrect
          onAccessCodeError();
        }
      };
      
      // Use requestAnimationFrame to ensure we check after the state has been updated
      requestAnimationFrame(checkAccessCodeValidity);
    } catch (error) {
      // Keep only essential error logging
      console.error('Error submitting access code:', error);
      onAccessCodeError();
    }
  };

  // Reset requiresAccessCode when accessCode changes
  useEffect(() => {
    if (accessCode) {
      setRequiresAccessCode(false);
      setIsValidating(false); // Reset validation state when access code is provided
    }
  }, [accessCode]);

  return (
    <Card className="mx-auto p-0 border-0 card-shadow">
      <Card.Header className="bg-white border-0">
      </Card.Header>
      <Card.Body>
        {requiresAccessCode || (isValidating && !accessCode) ? (
          <AccessCodeForm 
            onAccessCodeSubmit={handleAccessCodeSubmit} 
            error={accessCodeError}
            friendlyId={friendlyId}
          />
        ) : (
          <PublicRecordingsList 
            friendlyId={friendlyId} 
            accessCode={accessCode}
            onRequiresAccessCode={() => setRequiresAccessCode(true)}
          />
        )}
      </Card.Body>
    </Card>
  );
}

PublicRecordingsCard.propTypes = {
  accessCode: PropTypes.string,
  onAccessCodeSubmit: PropTypes.func.isRequired,
  onAccessCodeError: PropTypes.func.isRequired,
  accessCodeError: PropTypes.bool,
};

PublicRecordingsCard.defaultProps = {
  accessCode: '',
  accessCodeError: false,
};
