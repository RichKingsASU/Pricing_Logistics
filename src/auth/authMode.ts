export type AuthMode = 'anonymous-demo' | 'required-auth';

export function getAuthMode(): AuthMode {
    const mode = (import.meta.env.VITE_AUTH_MODE as string | undefined)?.trim();
    return mode === 'anonymous-demo' ? 'anonymous-demo' : 'required-auth';
}

export function isAnonymousDemoMode(): boolean {
    return getAuthMode() === 'anonymous-demo';
}
