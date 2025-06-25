'use client';

import { useState, useEffect, use } from 'react';
import { useRouter } from 'next/navigation';
import { doc, getDoc, addDoc, updateDoc, collection } from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, storage } from '../../../../../lib/firebase';
import { Video } from '../../../../../lib/types';
import AuthGuard from '../../../../../components/AuthGuard';
import Layout from '../../../../../components/Layout';

export default function VideoEditPage({ params }: { params: Promise<{ id: string }> }) {
  const router = useRouter();
  const resolvedParams = use(params);
  const isNew = resolvedParams.id === 'new';
  
  const [video, setVideo] = useState<Partial<Video>>({
    title: '',
    description: '',
    videoUrl: '',
    thumbnailUrl: '',
    category: '',
    likes: 0,
    views: 0,
    isActive: true,
    tags: []
  });
  const [loading, setLoading] = useState(!isNew);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [videoFile, setVideoFile] = useState<File | null>(null);
  const [thumbnailFile, setThumbnailFile] = useState<File | null>(null);

  useEffect(() => {
    if (!isNew) {
      loadVideo();
    }
  }, [isNew, resolvedParams.id]);

  const loadVideo = async () => {
    try {
      const docRef = doc(db, 'videos', resolvedParams.id);
      const docSnap = await getDoc(docRef);
      
      if (docSnap.exists()) {
        setVideo({ id: docSnap.id, ...docSnap.data() } as Video);
      } else {
        alert('動画が見つかりません');
        router.push('/admin');
      }
    } catch (error) {
      console.error('Error loading video:', error);
      alert('読み込みに失敗しました');
    } finally {
      setLoading(false);
    }
  };

  const uploadFile = async (file: File, path: string): Promise<string> => {
    const storageRef = ref(storage, path);
    const snapshot = await uploadBytes(storageRef, file);
    return await getDownloadURL(snapshot.ref);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setUploading(true);

    try {
      let videoUrl = video.videoUrl;
      let thumbnailUrl = video.thumbnailUrl;

      if (videoFile) {
        const videoPath = `videos/${Date.now()}_${videoFile.name}`;
        videoUrl = await uploadFile(videoFile, videoPath);
      }

      if (thumbnailFile) {
        const thumbnailPath = `videos/thumbnails/${Date.now()}_${thumbnailFile.name}`;
        thumbnailUrl = await uploadFile(thumbnailFile, thumbnailPath);
      }

      const data = {
        ...video,
        videoUrl,
        thumbnailUrl,
        updatedAt: new Date(),
        ...(isNew && { createdAt: new Date() })
      };

      if (isNew) {
        await addDoc(collection(db, 'videos'), data);
      } else {
        await updateDoc(doc(db, 'videos', resolvedParams.id), data);
      }

      router.push('/admin');
    } catch (error) {
      console.error('Error saving video:', error);
      alert('保存に失敗しました');
    } finally {
      setSaving(false);
      setUploading(false);
    }
  };

  const handleChange = (field: keyof Video, value: any) => {
    setVideo(prev => ({ ...prev, [field]: value }));
  };

  const handleVideoFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setVideoFile(file);
    }
  };

  const handleThumbnailFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setThumbnailFile(file);
    }
  };

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
        <div className="max-w-2xl mx-auto">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-white">
              {isNew ? '動画新規作成' : '動画編集'}
            </h1>
          </div>

          <form onSubmit={handleSubmit} className="bg-gray-800 rounded-lg p-6 space-y-6">
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-300 mb-2">
                タイトル *
              </label>
              <input
                id="title"
                type="text"
                value={video.title || ''}
                onChange={(e) => handleChange('title', e.target.value)}
                required
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="動画のタイトルを入力してください"
              />
            </div>

            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-300 mb-2">
                説明 *
              </label>
              <textarea
                id="description"
                value={video.description || ''}
                onChange={(e) => handleChange('description', e.target.value)}
                required
                rows={4}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="動画の説明を入力してください"
              />
            </div>

            <div>
              <label htmlFor="category" className="block text-sm font-medium text-gray-300 mb-2">
                カテゴリ *
              </label>
              <select
                id="category"
                value={video.category || ''}
                onChange={(e) => handleChange('category', e.target.value)}
                required
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">カテゴリを選択してください</option>
                <option value="Motivation">モチベーション</option>
                <option value="Success">成功</option>
                <option value="Inspiration">インスピレーション</option>
                <option value="Personal Development">自己啓発</option>
                <option value="Mindfulness">マインドフルネス</option>
                <option value="Goals">目標達成</option>
                <option value="Productivity">生産性</option>
              </select>
            </div>

            <div>
              <label htmlFor="videoFile" className="block text-sm font-medium text-gray-300 mb-2">
                動画ファイル {!isNew && video.videoUrl && '(現在のファイルを置き換える場合のみ選択)'}
              </label>
              <input
                id="videoFile"
                type="file"
                accept="video/*"
                onChange={handleVideoFileChange}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-600 file:text-white hover:file:bg-blue-700"
              />
              {video.videoUrl && !videoFile && (
                <p className="text-xs text-gray-400 mt-1">
                  現在のファイル: {video.videoUrl.split('/').pop()}
                </p>
              )}
            </div>

            <div>
              <label htmlFor="thumbnailFile" className="block text-sm font-medium text-gray-300 mb-2">
                サムネイル画像
              </label>
              <input
                id="thumbnailFile"
                type="file"
                accept="image/*"
                onChange={handleThumbnailFileChange}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-600 file:text-white hover:file:bg-blue-700"
              />
              {video.thumbnailUrl && !thumbnailFile && (
                <p className="text-xs text-gray-400 mt-1">
                  現在のサムネイル: {video.thumbnailUrl.split('/').pop()}
                </p>
              )}
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label htmlFor="likes" className="block text-sm font-medium text-gray-300 mb-2">
                  いいね数
                </label>
                <input
                  id="likes"
                  type="number"
                  value={video.likes || 0}
                  onChange={(e) => handleChange('likes', parseInt(e.target.value))}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
              <div>
                <label htmlFor="views" className="block text-sm font-medium text-gray-300 mb-2">
                  再生回数
                </label>
                <input
                  id="views"
                  type="number"
                  value={video.views || 0}
                  onChange={(e) => handleChange('views', parseInt(e.target.value))}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>
            </div>

            <div>
              <label htmlFor="tags" className="block text-sm font-medium text-gray-300 mb-2">
                タグ（カンマ区切り）
              </label>
              <input
                id="tags"
                type="text"
                value={video.tags?.join(', ') || ''}
                onChange={(e) => handleChange('tags', e.target.value.split(',').map(tag => tag.trim()).filter(tag => tag))}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="例: やる気, 成功マインド, 目標設定"
              />
            </div>

            <div className="flex items-center">
              <input
                id="isActive"
                type="checkbox"
                checked={video.isActive || false}
                onChange={(e) => handleChange('isActive', e.target.checked)}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="isActive" className="ml-2 block text-sm text-gray-300">
                有効にする
              </label>
            </div>

            <div className="flex justify-end space-x-4">
              <button
                type="button"
                onClick={() => router.push('/admin')}
                className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-md transition duration-200"
              >
                キャンセル
              </button>
              <button
                type="submit"
                disabled={saving}
                className="px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-800 disabled:cursor-not-allowed text-white rounded-md transition duration-200"
              >
                {uploading ? 'アップロード中...' : saving ? '保存中...' : '保存'}
              </button>
            </div>
          </form>
        </div>
      </Layout>
    </AuthGuard>
  );
}