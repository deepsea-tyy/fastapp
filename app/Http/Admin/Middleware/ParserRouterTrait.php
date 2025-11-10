<?php
/**
 * FastApp.
 * 10/16/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Admin\Middleware;

trait ParserRouterTrait
{
    final protected function parse(mixed $callback): ?array
    {
        if (\is_array($callback) && \count($callback) === 2) {
            return $callback;
        }
        if (\is_string($callback)) {
            if (str_contains($callback, '@')) {
                $exp = explode('@', $callback);
            }
            if (str_contains($callback, '::')) {
                $exp = explode('::', $callback);
            }
            if (isset($exp) && \count($exp) === 2) {
                return $exp;
            }
        }
        return null;
    }

}