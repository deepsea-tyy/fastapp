<?php
/**
 * FastApp.
 * 10/19/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

namespace App\Common\Excel;

use PhpOffice\PhpSpreadsheet\Cell\Coordinate;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Reader\Exception as ReaderException;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

/**
 * 通用Excel导入抽象类
        $import = new UserImport();
        $import->setHeaderRows(2)->setChunkSize(10);

        if ($import->loadFile('xxxx.xlsx')) {
            while ($import->hasMoreData()) {
                $data = $import->readData(true);
                foreach ($data as $index => $row) {
                    if ($import->validateRow($row, $index)) {
                        $import->processRow($row, $index);
                    }
                }
            }
        }
 */
abstract class AbsImport
{
    /**
     * @var Spreadsheet Excel对象
     */
    protected Spreadsheet $spreadsheet;

    /**
     * @var Worksheet 工作表对象
     */
    protected Worksheet $worksheet;

    /**
     * @var array 导入数据
     */
    protected array $importData = [];

    /**
     * @var array 错误信息
     */
    protected array $errors = [];

    /**
     * @var int 数据起始行（默认从第2行开始，跳过标题行）
     */
    protected int $startRow = 2;

    /**
     * @var int 标题行数（默认为1行）
     */
    protected int $headerRows = 1;

    /**
     * @var int 最大导入行数限制
     */
    protected int $maxRows = 1000;

    /**
     * @var int 分片大小（每次读取的行数，默认1000行）
     */
    protected int $chunkSize = 1000;

    /**
     * @var int 当前分片起始行
     */
    protected int $currentChunkStart = 0;

    /**
     * @var bool 是否已读取完所有数据
     */
    protected bool $isFinished = false;

    /**
     * 加载Excel文件
     *
     * @param string $filePath 文件路径
     * @param int $sheetIndex 工作表索引
     * @return bool
     */
    public function loadFile(string $filePath, int $sheetIndex = 0): bool
    {
        try {
            $this->spreadsheet = IOFactory::load($filePath);
            $this->worksheet = $this->spreadsheet->getSheet($sheetIndex);
            $this->errors = [];
            return true;
        } catch (ReaderException $e) {
            $this->errors[] = "文件加载失败: " . $e->getMessage();
            return false;
        }
    }

    /**
     * 读取Excel数据（支持分片读取）
     *
     * @param bool $chunkMode 是否启用分片模式
     * @return array
     */
    public function readData(bool $chunkMode = false): array
    {
        if (!$this->worksheet) {
            $this->errors[] = "请先加载Excel文件";
            return [];
        }

        if ($chunkMode && $this->isFinished) {
            return [];
        }

        $this->importData = [];
        $highestRow = $this->worksheet->getHighestRow();
        $highestColumn = $this->worksheet->getHighestColumn();
        $highestColumnIndex = Coordinate::columnIndexFromString($highestColumn);

        // 计算读取范围
        if ($chunkMode) {
            $startRow = $this->currentChunkStart > 0 ? $this->currentChunkStart : $this->startRow;
            $endRow = min($highestRow, $startRow + $this->chunkSize - 1, $this->startRow + $this->maxRows - 1);

            if ($startRow > $endRow) {
                $this->isFinished = true;
                return [];
            }
        } else {
            $startRow = $this->startRow;
            $endRow = min($highestRow, $this->startRow + $this->maxRows - 1);
            $this->resetChunk(); // 重置分片状态
        }

        for ($row = $startRow; $row <= $endRow; $row++) {
            $rowData = [];
            $isEmptyRow = true;

            for ($col = 1; $col <= $highestColumnIndex; $col++) {
                $cellCoordinate = Coordinate::stringFromColumnIndex($col) . $row;
                $cellValue = $this->worksheet->getCell($cellCoordinate)->getCalculatedValue();
                $rowData[] = $cellValue;

                if ($cellValue !== null && $cellValue !== '' && trim($cellValue) !== '') {
                    $isEmptyRow = false;
                }
            }

            if (!$isEmptyRow) {
                $this->importData[] = $rowData;
            }
        }

        if ($chunkMode) {
            $this->currentChunkStart = $endRow + 1;
            if ($this->currentChunkStart > min($highestRow, $this->startRow + $this->maxRows - 1)) {
                $this->isFinished = true;
            }
        }

        return $this->importData;
    }

    /**
     * 重置分片读取状态
     *
     * @return self
     */
    public function resetChunk(): self
    {
        $this->currentChunkStart = 0;
        $this->isFinished = false;
        $this->importData = [];
        return $this;
    }

    /**
     * 检查是否还有更多数据可读
     *
     * @return bool
     */
    public function hasMoreData(): bool
    {
        if ($this->isFinished) {
            return false;
        }

        $highestRow = $this->worksheet->getHighestRow();
        $currentStart = $this->currentChunkStart > 0 ? $this->currentChunkStart : $this->startRow;
        $maxAllowedRow = min($highestRow, $this->startRow + $this->maxRows - 1);

        return $currentStart <= $maxAllowedRow;
    }

    /**
     * 获取错误信息
     *
     * @return array
     */
    public function getErrors(): array
    {
        return $this->errors;
    }

    /**
     * 设置数据起始行
     *
     * @param int $startRow
     * @return self
     */
    public function setStartRow(int $startRow): self
    {
        $this->startRow = max(1, $startRow);
        return $this;
    }

    /**
     * 设置最大导入行数
     *
     * @param int $maxRows
     * @return self
     */
    public function setMaxRows(int $maxRows): self
    {
        $this->maxRows = max(1, $maxRows);
        return $this;
    }

    /**
     * 设置标题行数
     *
     * @param int $headerRows
     * @return self
     */
    public function setHeaderRows(int $headerRows): self
    {
        $this->headerRows = max(0, $headerRows);
        $this->startRow = $this->headerRows + 1;
        return $this;
    }

    /**
     * 设置分片大小
     *
     * @param int $chunkSize
     * @return self
     */
    public function setChunkSize(int $chunkSize): self
    {
        $this->chunkSize = max(1, $chunkSize);
        return $this;
    }

    /**
     * 获取标题行数据
     *
     * @return array
     */
    public function getHeaderData(): array
    {
        if (!$this->worksheet) {
            $this->errors[] = "请先加载Excel文件";
            return [];
        }

        $headerData = [];
        $highestColumn = $this->worksheet->getHighestColumn();
        $highestColumnIndex = Coordinate::columnIndexFromString($highestColumn);

        for ($row = 1; $row <= $this->headerRows; $row++) {
            $rowData = [];
            for ($col = 1; $col <= $highestColumnIndex; $col++) {
                $cellCoordinate = Coordinate::stringFromColumnIndex($col) . $row;
                $cellValue = $this->worksheet->getCell($cellCoordinate)->getCalculatedValue();
                $rowData[] = $cellValue;
            }
            $headerData[] = $rowData;
        }

        return $headerData;
    }

    /**
     * 获取导入数据统计
     *
     * @return array
     */
    public function getStatistics(): array
    {
        return [
            'total_rows' => count($this->importData),
            'error_count' => count($this->errors),
            'start_row' => $this->startRow,
            'max_rows' => $this->maxRows,
            'header_rows' => $this->headerRows,
            'chunk_size' => $this->chunkSize,
            'is_finished' => $this->isFinished
        ];
    }


    /**
     * 验证单行数据（抽象方法，子类必须实现）
     *
     * @param array $rowData 行数据
     * @param int $rowIndex 行索引
     * @return bool
     */
    abstract public function validateRow(array $rowData, int $rowIndex): bool;

    /**
     * 处理单行数据（抽象方法，子类必须实现）
     *
     * @param array $rowData 行数据
     * @param int $rowIndex 行索引
     * @return bool
     */
    abstract public function processRow(array $rowData, int $rowIndex): bool;
}