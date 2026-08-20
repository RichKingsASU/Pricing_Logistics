function getCookie(name: string) {
  let cookieValue = null;
  if (document.cookie && document.cookie !== '') {
    const cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
      const cookie = cookies[i].trim();
      if (cookie.substring(0, name.length + 1) === (name + '=')) {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}

const fetchApi = async (url: string, options: RequestInit = {}) => {
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (options.method && ['POST', 'PUT', 'PATCH', 'DELETE'].includes(options.method.toUpperCase())) {
    const csrfToken = getCookie('csrftoken');
    if (csrfToken) {
      headers['X-CSRFToken'] = csrfToken;
    }
  }

  const response = await fetch(url, { credentials: 'include', ...options, headers });
  
  if (!response.ok) {
    if (response.status === 401 || response.status === 403 || response.status === 404) {
       // Return null/empty instead of crashing entirely for some gets, or let it throw
       const errorData = await response.json().catch(() => ({}));
       throw new Error(errorData.error || `HTTP error! status: ${response.status}`);
    }
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return response.json();
};

export const authService = {
  async getSession() {
    try {
      const res = await fetchApi('/api/auth/me/');
      if (res.status === 'authenticated') {
         return { user: { username: res.username } };
      }
      return null;
    } catch (e) {
      return null;
    }
  },
  async signOut() {
    await fetchApi('/api/auth/logout/', { method: 'POST' });
  },
  async getCurrentOrganizationId() {
    try {
      const res = await fetchApi('/customers/api/organizations/current/');
      if (res && res.length > 0) {
        return res[0].id;
      }
      return null;
    } catch (e) {
      console.error('Error fetching org:', e);
      return null;
    }
  }
};

export const marketService = {
  async getMarkets(orgId: string) {
    return await fetchApi(`/pricing/api/market_summaries/?orgId=${orgId}`);
  },
  async updateMarket(id: string, updates: any) {
    return await fetchApi(`/pricing/api/market_summaries/${id}/`, { method: 'PATCH', body: JSON.stringify(updates) });
  }
};

export const exceptionService = {
  async getExceptions(orgId: string) {
    return await fetchApi(`/pricing/api/lane_exceptions/?orgId=${orgId}`);
  },
  async updateException(id: string, updates: any) {
    return await fetchApi(`/pricing/api/lane_exceptions/${id}/`, { method: 'PATCH', body: JSON.stringify(updates) });
  }
};

export const adjustmentService = {
  async getAdjustments(orgId: string) {
    return await fetchApi(`/pricing/api/pricing_adjustments/?orgId=${orgId}`);
  },
  async createAdjustment(adjustment: any) {
    return await fetchApi('/pricing/api/pricing_adjustments/', {
      method: 'POST',
      body: JSON.stringify(adjustment)
    });
  }
};

export const rateLaneService = {
  async getCustomerLanes(orgId: string) {
    return await fetchApi(`/rates/api/customer_rate_lanes/?orgId=${orgId}`);
  },
  async updateCustomerLane(id: string, updates: any) {
    return await fetchApi(`/rates/api/customer_rate_lanes/${id}/`, { method: 'PATCH', body: JSON.stringify(updates) });
  },
  async createCustomerLane(lane: any) {
    return await fetchApi('/rates/api/customer_rate_lanes/', { method: 'POST', body: JSON.stringify(lane) });
  }
};
