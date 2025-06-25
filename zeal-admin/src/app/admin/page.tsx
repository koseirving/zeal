'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { collection, getDocs, deleteDoc, doc, updateDoc } from 'firebase/firestore';
import { db } from '../../../lib/firebase';
import { Affirmation, Music, Video, ContentType } from '../../../lib/types';
import AuthGuard from '../../../components/AuthGuard';
import Layout from '../../../components/Layout';
import CSVImport from '../../../components/CSVImport';
import MediaPreview from '../../../components/MediaPreview';

export default function AdminPage() {
  const [activeTab, setActiveTab] = useState<ContentType>('affirmations');
  const [affirmations, setAffirmations] = useState<Affirmation[]>([]);
  const [music, setMusic] = useState<Music[]>([]);
  const [videos, setVideos] = useState<Video[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadContent();
  }, []);

  const loadContent = async () => {
    setLoading(true);
    try {
      const [affirmationsSnapshot, musicSnapshot, videosSnapshot] = await Promise.all([
        getDocs(collection(db, 'affirmations')),
        getDocs(collection(db, 'music')),
        getDocs(collection(db, 'videos'))
      ]);

      setAffirmations(affirmationsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Affirmation)));
      setMusic(musicSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Music)));
      setVideos(videosSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Video)));
    } catch (error) {
      console.error('Error loading content:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (type: ContentType, id: string) => {
    if (!confirm('このアイテムを削除しますか？')) return;

    try {
      await deleteDoc(doc(db, type, id));
      loadContent();
    } catch (error) {
      console.error('Error deleting content:', error);
      alert('削除に失敗しました');
    }
  };

  const handleToggleActive = async (type: ContentType, id: string, currentStatus: boolean) => {
    try {
      await updateDoc(doc(db, type, id), { isActive: !currentStatus });
      loadContent();
    } catch (error) {
      console.error('Error updating content:', error);
      alert('更新に失敗しました');
    }
  };

  const renderAffirmations = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">アファメーション ({affirmations.length})</h2>
        <div className="flex space-x-2">
          <CSVImport onImportComplete={loadContent} />
          <Link 
            href="/admin/affirmations/new"
            className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md"
          >
            新規追加
          </Link>
        </div>
      </div>
      
      <div className="bg-gray-800 rounded-lg overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-700">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">テキスト</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">カテゴリ</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">ステータス</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-700">
            {affirmations.map((item) => (
              <tr key={item.id}>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300 max-w-xs truncate">
                  {item.text}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  {item.category}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <button
                    onClick={() => handleToggleActive('affirmations', item.id!, item.isActive)}
                    className={`px-2 py-1 rounded-full text-xs ${
                      item.isActive ? 'bg-green-800 text-green-300' : 'bg-red-800 text-red-300'
                    }`}
                  >
                    {item.isActive ? '有効' : '無効'}
                  </button>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                  <Link
                    href={`/admin/affirmations/${item.id}`}
                    className="text-blue-400 hover:text-blue-300"
                  >
                    編集
                  </Link>
                  <button
                    onClick={() => handleDelete('affirmations', item.id!)}
                    className="text-red-400 hover:text-red-300"
                  >
                    削除
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {affirmations.length === 0 && (
          <div className="text-center py-8 text-gray-400">
            アファメーションがありません
          </div>
        )}
      </div>
    </div>
  );

  const renderMusic = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">音楽 ({music.length})</h2>
        <Link 
          href="/admin/music/new"
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md"
        >
          新規追加
        </Link>
      </div>
      
      <div className="bg-gray-800 rounded-lg overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-700">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">タイトル</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">アーティスト</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">カテゴリ</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">ステータス</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-700">
            {music.map((item) => (
              <tr key={item.id}>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  {item.title}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  {item.artist}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  {item.category}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <button
                    onClick={() => handleToggleActive('music', item.id!, item.isActive)}
                    className={`px-2 py-1 rounded-full text-xs ${
                      item.isActive ? 'bg-green-800 text-green-300' : 'bg-red-800 text-red-300'
                    }`}
                  >
                    {item.isActive ? '有効' : '無効'}
                  </button>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                  {item.audioUrl && (
                    <MediaPreview
                      type="audio"
                      url={item.audioUrl}
                      title={item.title}
                    />
                  )}
                  <Link
                    href={`/admin/music/${item.id}`}
                    className="text-blue-400 hover:text-blue-300"
                  >
                    編集
                  </Link>
                  <button
                    onClick={() => handleDelete('music', item.id!)}
                    className="text-red-400 hover:text-red-300"
                  >
                    削除
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {music.length === 0 && (
          <div className="text-center py-8 text-gray-400">
            音楽がありません
          </div>
        )}
      </div>
    </div>
  );

  const renderVideos = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">動画 ({videos.length})</h2>
        <Link 
          href="/admin/videos/new"
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md"
        >
          新規追加
        </Link>
      </div>
      
      <div className="bg-gray-800 rounded-lg overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-700">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">タイトル</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">説明</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">カテゴリ</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">ステータス</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">操作</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-700">
            {videos.map((item) => (
              <tr key={item.id}>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  {item.title}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300 max-w-xs truncate">
                  {item.description}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                  {item.category}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <button
                    onClick={() => handleToggleActive('videos', item.id!, item.isActive)}
                    className={`px-2 py-1 rounded-full text-xs ${
                      item.isActive ? 'bg-green-800 text-green-300' : 'bg-red-800 text-red-300'
                    }`}
                  >
                    {item.isActive ? '有効' : '無効'}
                  </button>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                  {item.videoUrl && (
                    <MediaPreview
                      type="video"
                      url={item.videoUrl}
                      title={item.title}
                    />
                  )}
                  <Link
                    href={`/admin/videos/${item.id}`}
                    className="text-blue-400 hover:text-blue-300"
                  >
                    編集
                  </Link>
                  <button
                    onClick={() => handleDelete('videos', item.id!)}
                    className="text-red-400 hover:text-red-300"
                  >
                    削除
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {videos.length === 0 && (
          <div className="text-center py-8 text-gray-400">
            動画がありません
          </div>
        )}
      </div>
    </div>
  );

  if (loading) {
    return (
      <AuthGuard>
        <Layout>
          <div className="flex items-center justify-center h-64">
            <div className="text-gray-400">読み込み中...</div>
          </div>
        </Layout>
      </AuthGuard>
    );
  }

  return (
    <AuthGuard>
      <Layout>
        <div className="space-y-6">
          <div className="border-b border-gray-700">
            <nav className="flex space-x-8">
              <button
                onClick={() => setActiveTab('affirmations')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'affirmations'
                    ? 'border-blue-500 text-blue-400'
                    : 'border-transparent text-gray-400 hover:text-gray-300'
                }`}
              >
                アファメーション
              </button>
              <button
                onClick={() => setActiveTab('music')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'music'
                    ? 'border-blue-500 text-blue-400'
                    : 'border-transparent text-gray-400 hover:text-gray-300'
                }`}
              >
                音楽
              </button>
              <button
                onClick={() => setActiveTab('videos')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'videos'
                    ? 'border-blue-500 text-blue-400'
                    : 'border-transparent text-gray-400 hover:text-gray-300'
                }`}
              >
                動画
              </button>
            </nav>
          </div>

          <div>
            {activeTab === 'affirmations' && renderAffirmations()}
            {activeTab === 'music' && renderMusic()}
            {activeTab === 'videos' && renderVideos()}
          </div>
        </div>
      </Layout>
    </AuthGuard>
  );
}