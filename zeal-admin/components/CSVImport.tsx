'use client';

import { useState } from 'react';
import { collection, addDoc } from 'firebase/firestore';
import { db } from '../lib/firebase';
import { Affirmation } from '../lib/types';

interface CSVImportProps {
  onImportComplete: () => void;
}

export default function CSVImport({ onImportComplete }: CSVImportProps) {
  const [file, setFile] = useState<File | null>(null);
  const [importing, setImporting] = useState(false);
  const [showModal, setShowModal] = useState(false);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (selectedFile && selectedFile.type === 'text/csv') {
      setFile(selectedFile);
    } else {
      alert('CSVファイルを選択してください');
    }
  };

  const parseCSV = (text: string): Partial<Affirmation>[] => {
    const lines = text.split('\n').filter(line => line.trim());
    const headers = lines[0].split(',').map(h => h.trim());
    
    return lines.slice(1).map(line => {
      const values = line.split(',').map(v => v.trim().replace(/^"|"$/g, ''));
      const item: Partial<Affirmation> = {
        isActive: true,
        viewCount: 0,
        createdAt: new Date(),
        updatedAt: new Date()
      };

      headers.forEach((header, index) => {
        const value = values[index];
        switch (header.toLowerCase()) {
          case 'text':
          case 'テキスト':
            item.text = value;
            break;
          case 'category':
          case 'カテゴリ':
            item.category = value;
            break;
          case 'tags':
          case 'タグ':
            if (value) {
              item.tags = value.split(';').map(tag => tag.trim()).filter(tag => tag);
            }
            break;
          case 'active':
          case 'isactive':
          case '有効':
            item.isActive = value.toLowerCase() === 'true' || value === '1' || value === 'はい';
            break;
        }
      });

      return item;
    }).filter(item => item.text && item.category);
  };

  const handleImport = async () => {
    if (!file) return;

    setImporting(true);
    try {
      const text = await file.text();
      const items = parseCSV(text);

      if (items.length === 0) {
        alert('有効なデータが見つかりませんでした');
        return;
      }

      const batch = items.map(item => addDoc(collection(db, 'affirmations'), item));
      await Promise.all(batch);

      alert(`${items.length}件のアファメーションをインポートしました`);
      setShowModal(false);
      setFile(null);
      onImportComplete();
    } catch (error) {
      console.error('Import error:', error);
      alert('インポートに失敗しました');
    } finally {
      setImporting(false);
    }
  };

  const downloadTemplate = () => {
    const csvContent = 'text,category,tags,active\n"私は成功している","Success","自信;成功","true"\n"私は健康で幸せです","Health","健康;幸福","true"';
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', 'affirmations_template.csv');
    link.click();
  };

  return (
    <>
      <button
        onClick={() => setShowModal(true)}
        className="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md mr-2"
      >
        CSV一括インポート
      </button>

      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-gray-800 rounded-lg p-6 max-w-md w-full mx-4">
            <h3 className="text-lg font-semibold text-white mb-4">CSVインポート</h3>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  CSVファイルを選択
                </label>
                <input
                  type="file"
                  accept=".csv"
                  onChange={handleFileChange}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-600 file:text-white hover:file:bg-blue-700"
                />
              </div>

              <div className="text-sm text-gray-400">
                <p className="mb-2">CSVフォーマット:</p>
                <ul className="list-disc list-inside space-y-1">
                  <li>text（必須）: アファメーションのテキスト</li>
                  <li>category（必須）: カテゴリ</li>
                  <li>tags（オプション）: セミコロン区切りのタグ</li>
                  <li>active（オプション）: true/false</li>
                </ul>
              </div>

              <button
                onClick={downloadTemplate}
                className="text-blue-400 hover:text-blue-300 text-sm underline"
              >
                テンプレートをダウンロード
              </button>

              <div className="flex justify-end space-x-4 pt-4">
                <button
                  onClick={() => {
                    setShowModal(false);
                    setFile(null);
                  }}
                  className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-md"
                >
                  キャンセル
                </button>
                <button
                  onClick={handleImport}
                  disabled={!file || importing}
                  className="px-4 py-2 bg-green-600 hover:bg-green-700 disabled:bg-green-800 disabled:cursor-not-allowed text-white rounded-md"
                >
                  {importing ? 'インポート中...' : 'インポート'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
}