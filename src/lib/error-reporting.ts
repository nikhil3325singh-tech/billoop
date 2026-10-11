export function reportAppError(error: unknown, context: Record<string, unknown> = {}) {
  if (typeof process !== "undefined" && process.env && process.env['NODE_ENV'] !== "production") {
    console.error("[AppError]", error, context);
  }
}
