import { describe, it, expect, beforeAll } from 'vitest';
import { getTestApp } from './helpers/testApp.js';

describe('GET /api/channels', () => {
  let request: Awaited<ReturnType<typeof getTestApp>>;

  beforeAll(async () => {
    request = await getTestApp();
  });

  it('returns array of OCP channels derived from catalog data', async () => {
    const res = await request.get('/api/channels');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThanOrEqual(1);
    expect(res.body).toContain('stable-4.21');
    for (const channel of res.body) {
      expect(channel).toMatch(/^stable-\d+\.\d+$/);
    }
  });
});
