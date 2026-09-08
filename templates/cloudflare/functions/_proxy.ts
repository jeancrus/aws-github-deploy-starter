type ProxyEnv = {
  BACKEND_API_URL?: string;
};

type ProxyContext = {
  request: Request;
  env: ProxyEnv;
};

/**
 * Same-origin proxy to the EC2 API.
 * BACKEND_API_URL must be an EC2 public DNS hostname (or custom DNS), never a raw IP.
 * Include the API port, e.g. http://ec2-….compute.amazonaws.com:3000
 */
export async function proxyToBackend(context: ProxyContext): Promise<Response> {
  const backendOrigin = context.env.BACKEND_API_URL?.replace(/\/+$/, "");
  if (!backendOrigin) {
    return new Response("BACKEND_API_URL is not configured", { status: 500 });
  }

  const url = new URL(context.request.url);
  const targetUrl = new URL(url.pathname + url.search, backendOrigin);

  const headers = new Headers(context.request.headers);
  headers.set("X-Forwarded-Host", url.host);
  headers.set("X-Forwarded-Proto", url.protocol.replace(":", ""));
  headers.delete("host");

  const method = context.request.method;
  const hasBody = method !== "GET" && method !== "HEAD";

  return fetch(targetUrl, {
    method,
    headers,
    body: hasBody ? context.request.body : undefined,
    redirect: "follow",
  });
}
