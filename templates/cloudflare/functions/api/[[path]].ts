import { proxyToBackend } from "../_proxy";

export async function onRequest(context: {
  request: Request;
  env: { BACKEND_API_URL?: string };
}): Promise<Response> {
  return proxyToBackend(context);
}
