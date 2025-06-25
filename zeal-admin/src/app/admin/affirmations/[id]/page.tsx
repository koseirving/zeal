'use client';

import { useState, useEffect, use } from 'react';
import { useRouter } from 'next/navigation';
import { doc, getDoc, addDoc, updateDoc, collection } from 'firebase/firestore';
import { db } from '../../../../../lib/firebase';
import { Affirmation } from '../../../../../lib/types';
import AuthGuard from '../../../../../components/AuthGuard';
import Layout from '../../../../../components/Layout';

export default function AffirmationEditPage({ params }: { params: Promise<{ id: string }> }) {
  const router = useRouter();
  const resolvedParams = use(params);
  const isNew = resolvedParams.id === 'new';
  
  const [affirmation, setAffirmation] = useState<Partial<Affirmation>>({
    text: '',
    category: '',
    isActive: true,
    viewCount: 0,
    tags: []
  });
  const [loading, setLoading] = useState(!isNew);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!isNew) {
      loadAffirmation();
    }
  }, [isNew, resolvedParams.id]);

  const loadAffirmation = async () => {
    try {
      const docRef = doc(db, 'affirmations', resolvedParams.id);
      const docSnap = await getDoc(docRef);
      
      if (docSnap.exists()) {
        setAffirmation({ id: docSnap.id, ...docSnap.data() } as Affirmation);
      } else {
        alert('アファメーションが見つかりません');
        router.push('/admin');
      }
    } catch (error) {
      console.error('Error loading affirmation:', error);
      alert('読み込みに失敗しました');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);

    try {
      const data = {
        ...affirmation,
        updatedAt: new Date(),
        ...(isNew && { createdAt: new Date() })
      };

      if (isNew) {
        await addDoc(collection(db, 'affirmations'), data);
      } else {
        await updateDoc(doc(db, 'affirmations', resolvedParams.id), data);
      }

      router.push('/admin');
    } catch (error) {
      console.error('Error saving affirmation:', error);
      alert('保存に失敗しました');
    } finally {
      setSaving(false);
    }
  };

  const handleChange = (field: keyof Affirmation, value: any) => {
    setAffirmation(prev => ({ ...prev, [field]: value }));
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
              {isNew ? 'アファメーション新規作成' : 'アファメーション編集'}
            </h1>
          </div>

          <form onSubmit={handleSubmit} className="bg-gray-800 rounded-lg p-6 space-y-6">
            <div>
              <label htmlFor="text" className="block text-sm font-medium text-gray-300 mb-2">
                テキスト *
              </label>
              <textarea
                id="text"
                value={affirmation.text || ''}
                onChange={(e) => handleChange('text', e.target.value)}
                required
                rows={4}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="アファメーションのテキストを入力してください"
              />
            </div>

            <div>
              <label htmlFor="category" className="block text-sm font-medium text-gray-300 mb-2">
                カテゴリ *
              </label>
              <select
                id="category"
                value={affirmation.category || ''}
                onChange={(e) => handleChange('category', e.target.value)}
                required
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">カテゴリを選択してください</option>
                <option value="Success">成功</option>
                <option value="Health">健康</option>
                <option value="Wealth">富</option>
                <option value="Love">愛</option>
                <option value="Happiness">幸福</option>
                <option value="Confidence">自信</option>
                <option value="Peace">平和</option>
                <option value="Growth">成長</option>
              </select>
            </div>

            <div>
              <label htmlFor="tags" className="block text-sm font-medium text-gray-300 mb-2">
                タグ（カンマ区切り）
              </label>
              <input
                id="tags"
                type="text"
                value={affirmation.tags?.join(', ') || ''}
                onChange={(e) => handleChange('tags', e.target.value.split(',').map(tag => tag.trim()).filter(tag => tag))}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="例: モチベーション, 目標達成, ポジティブ"
              />
            </div>

            <div className="flex items-center">
              <input
                id="isActive"
                type="checkbox"
                checked={affirmation.isActive || false}
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
                {saving ? '保存中...' : '保存'}
              </button>
            </div>
          </form>
        </div>
      </Layout>
    </AuthGuard>
  );
}