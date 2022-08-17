import React from 'react';
import { Card } from 'react-bootstrap';
import { CloudUploadIcon } from '@heroicons/react/outline';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';
import FilesDragAndDrop from '../../../shared_components/utilities/FilesDragAndDrop';

export default function BrandingImage() {
  const updateSiteSetting = useUpdateSiteSetting('BrandingImage');

  return (
    <div className="mb-3">
      <h5> Branding Image </h5>
      <FilesDragAndDrop
        numOfFiles={1}
        onDrop={(files) => updateSiteSetting.mutate(files[0])}
        formats={['.jpg', '.png', '.svg']}
      >
        <Card className="border border-2 border-whitesmoke mt-3 text-center">
          <label htmlFor="file" className="presentation-upload">
            <Card.Body className="py-5 text-secondary cursor-pointer">
              <div className="icon-circle rounded-circle d-block mx-auto mb-3">
                <CloudUploadIcon className="hi-l text-brand d-block mx-auto pt-4" />
              </div>
              <input
                id="file"
                className="d-none"
                type="file"
                onChange={(e) => updateSiteSetting.mutate(e.target.files[0])}
                accept=".jpg,.png,.svg"
              />
              <Card.Title className="text-brand">
                Click to Upload <span className="fs-5 fw-normal text-muted"> or drag and drop </span>
              </Card.Title>
              <span className="text-muted">
                Upload any PNG, JPG, or SVG file. Depending on the size of the
                presentation, it may require additional time to upload before it can be used
              </span>
            </Card.Body>
          </label>
        </Card>
      </FilesDragAndDrop>
    </div>
  );
}
