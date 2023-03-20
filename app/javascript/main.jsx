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

// Entry point for the build script in your package.json
import * as React from 'react';
import { render } from 'react-dom';
import { QueryClient, QueryClientProvider } from 'react-query';
import './i18n';
import AuthProvider from './contexts/auth/AuthProvider';
import App from './App';

const queryClientConfig = {
  defaultOptions: {
    queries: {
      useErrorBoundary: true,
    },
  },
};

const queryClient = new QueryClient(queryClientConfig);

const rootElement = document.getElementById('root');
render(
  // eslint-disable-next-line react/jsx-no-useless-fragment
  <React.Suspense fallback={<></>}>
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <App />
      </AuthProvider>
    </QueryClientProvider>
  </React.Suspense>,
  rootElement,
);
