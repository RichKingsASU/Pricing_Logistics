import React, { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import { AuthBootstrap } from './auth/AuthBootstrap';
import './index.css';

createRoot(document.getElementById('root')!).render(
    React.createElement(
          StrictMode,
          null,
          React.createElement(AuthBootstrap, null, React.createElement(App, null))
        )
  );
