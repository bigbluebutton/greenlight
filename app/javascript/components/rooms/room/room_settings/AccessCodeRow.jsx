import React from 'react';
import PropTypes from 'prop-types';
import { Button, Row, Stack } from 'react-bootstrap';
import { TrashIcon, DuplicateIcon, RefreshIcon } from '@heroicons/react/outline';
import { toast } from 'react-hot-toast';

// TODO: Extract this into a shared helper function.
const copyAccessCode = (code) => {
  navigator.clipboard.writeText(code);
  toast.success('Copied');
};

export default function AccessCodeRow({
  settingName, description, code, updateMutation: useUpdateAPI, config,
}) {
  const updateAPI = useUpdateAPI();
  const handleGenerateCode = () => updateAPI.mutate({ settingName, settingValue: true });
  const handleDeleteCode = () => updateAPI.mutate({ settingName, settingValue: false });

  if (config === 'false') {
    return null;
  }

  const deleteButton = config === 'optional' ? (
    <Button
      variant="font-awesome"
      onClick={handleDeleteCode}
    >
      <TrashIcon className="hi-s text-muted" />
    </Button>
  ) : null;

  return (
    <Row className="my-3">
      <h6 className="text-brand">{description}</h6>
      {
        code
          ? (
            <Stack direction="horizontal">
              <div className="access-code-input w-100">
                <input type="text" className="form-control" value={code} readOnly />
                <Button
                  variant="font-awesome"
                  onClick={() => copyAccessCode(code)}
                >
                  <DuplicateIcon className="hi-s text-muted" />
                </Button>
              </div>
              <Button
                variant="font-awesome"
                onClick={handleGenerateCode}
              >
                <RefreshIcon className="hi-s text-muted" />
              </Button>
              {deleteButton}
            </Stack>
          )
          : (
            <div>
              <Button
                variant="brand-backward"
                onClick={handleGenerateCode}
              >
                Generate
              </Button>
            </div>
          )
      }
    </Row>
  );
}
AccessCodeRow.defaultProps = {
  code: '',
  config: 'false',
};

AccessCodeRow.propTypes = {
  code: PropTypes.string,
  config: PropTypes.string,
  settingName: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  updateMutation: PropTypes.func.isRequired,
};
