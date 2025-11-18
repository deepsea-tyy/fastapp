<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Http\Admin;

use Hyperf\Di\Annotation\AbstractAnnotation;

#[\Attribute(\Attribute::TARGET_CLASS | \Attribute::TARGET_METHOD)]
final class Permission extends AbstractAnnotation
{
    public const OPERATION_AND = 'and';

    public const OPERATION_OR = 'or';

    public function __construct(
        protected array|string $code,
        protected string $operation = self::OPERATION_AND,
    ) {}

    public function getCode(): array
    {
        return \is_array($this->code) ? $this->code : [$this->code];
    }

    public function getOperation(): string
    {
        return $this->operation;
    }
}
