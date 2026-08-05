import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { isAnonymousDemoMode } from './authMode';

let authInitializationPromise: Promise<void> | null = null;

export function initializeAnonymousSession(): Promise<void> {
    if (authInitializationPromise) {
          return authInitializationPromise;
    }

  authInitializationPromise = (async () => {
        const {
                data: { session },
                error: sessionError
        } = await supabase.auth.getSession();

                                   if (sessionError) {
                                           throw sessionError;
                                   }

                                   if (!session) {
                                           const { error } = await supabase.auth.signInAnonymously();

          if (error) {
                    throw error;
          }
                                   }
  })();

  authInitializationPromise.catch(() => {
        authInitializationPromise = null;
  });

  return authInitializationPromise;
}


interface AuthBootstrapProps {
    children: React.ReactNode;
}

export const AuthBootstrap: React.FC<AuthBootstrapProps> = (props) => {
    const children = props.children;
    const [ready, setReady] = useState(false);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
          if (!isAnonymousDemoMode()) {
                  setReady(true);
                  return;
          }

                  let cancelled = false;

                  initializeAnonymousSession()
            .then(() => {
                      if (!cancelled) setReady(true);
            })
            .catch((err: any) => {
                      const message = err && err.message ? err.message : 'Failed to start demo session.';
                      if (!cancelled) setError(message);
            });

                  return () => {
                          cancelled = true;
                  };
    }, []);

    if (error) {
          return React.createElement(
                  'div',
            { className: 'min-h-screen flex items-center justify-center bg-slate-50 px-4' },
                  React.createElement(
                            'div',
                    { className: 'max-w-md text-center' },
                            React.createElement('p', { className: 'text-red-600 font-semibold mb-2' }, 'Unable to start the demo session'),
                            React.createElement('p', { className: 'text-slate-500 text-sm' }, error)
                          )
                );
    }

    if (!ready) {
          return React.createElement(
                  'div',
            { className: 'min-h-screen flex items-center justify-center bg-slate-50' },
                  React.createElement('div', { className: 'text-slate-500 animate-pulse' }, 'Preparing Pricing Control Tower...')
                );
    }

    return React.createElement(React.Fragment, null, children);
};
