'use client';

import { useState } from 'react';

interface MediaPreviewProps {
  type: 'audio' | 'video';
  url: string;
  title: string;
}

export default function MediaPreview({ type, url, title }: MediaPreviewProps) {
  const [showPreview, setShowPreview] = useState(false);

  if (!url) return null;

  return (
    <>
      <button
        onClick={() => setShowPreview(true)}
        className="text-blue-400 hover:text-blue-300 text-sm"
      >
        プレビュー
      </button>

      {showPreview && (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
          <div className="bg-gray-800 rounded-lg p-6 max-w-2xl w-full mx-4">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold text-white">{title}</h3>
              <button
                onClick={() => setShowPreview(false)}
                className="text-gray-400 hover:text-white text-2xl"
              >
                ×
              </button>
            </div>
            
            <div className="bg-gray-900 rounded-lg p-4">
              {type === 'audio' ? (
                <audio
                  controls
                  className="w-full"
                  preload="metadata"
                >
                  <source src={url} type="audio/mpeg" />
                  <source src={url} type="audio/wav" />
                  <source src={url} type="audio/ogg" />
                  お使いのブラウザは音声の再生をサポートしていません。
                </audio>
              ) : (
                <video
                  controls
                  className="w-full max-h-96"
                  preload="metadata"
                >
                  <source src={url} type="video/mp4" />
                  <source src={url} type="video/webm" />
                  <source src={url} type="video/ogg" />
                  お使いのブラウザは動画の再生をサポートしていません。
                </video>
              )}
            </div>

            <div className="flex justify-end mt-4">
              <button
                onClick={() => setShowPreview(false)}
                className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-md"
              >
                閉じる
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}