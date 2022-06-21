import React from 'react';
import { Button, Row } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import useGenerateAccessCode from '../../hooks/mutations/rooms/useGenerateAccessCode';
import useDeleteAccessCode from '../../hooks/mutations/rooms/useDeleteAccessCode';
import useAccessCodes from '../../hooks/queries/rooms/useAccessCodes';

export default function AccessCodes() {
  const { friendlyId } = useParams();
  const { handleGenerateAccessCode } = useGenerateAccessCode(friendlyId);
  const { handleDeleteAccessCode } = useDeleteAccessCode(friendlyId);
  const { data: accessCodes } = useAccessCodes(friendlyId);

  return (
    <>
      <Row>
        <h6 className="text-primary">Generate access code for viewers</h6>
        <div>
          <Button
            variant="primary-light"
            onClick={() => handleGenerateAccessCode('Viewer')}
          >
            Generate
          </Button>
        </div>
        {
          accessCodes?.viewer_access_code
        }
        <div>
          <Button
            variant="danger"
            onClick={() => handleDeleteAccessCode('Viewer')}
          >
            Remove
          </Button>
        </div>
      </Row>
      <Row>
        <h6 className="text-primary">Generate access code for moderators</h6>
        <div>
          <Button
            variant="primary-light"
            onClick={() => handleGenerateAccessCode('Moderator')}
          >
            Generate
          </Button>
        </div>
        {
          accessCodes?.moderator_access_code
        }
        <div>
          <Button
            variant="danger"
            onClick={() => handleDeleteAccessCode('Moderator')}
          >
            Remove
          </Button>
        </div>
      </Row>
    </>
  );
}
