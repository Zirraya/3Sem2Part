import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { logout } from './authSlice';

interface IDataState {
  posts: IPost[];
  comments: IComment[];
  products: IProduct[];
}

interface IPost {
  id: number;
  title: string;
  content: string;
  userId: number;
}

interface IComment {
  id: number;
  text: string;
  postId: number;
}

interface IProduct {
  id: number;
  name: string;
  price: number;
  description: string;
}

const initialState: IDataState = {
  posts: [],
  comments: [],
  products: [],
};

const dataSlice = createSlice({
  name: 'data',
  initialState,
  reducers: {
    setPosts: (state, action: PayloadAction<IPost[]>) => {
      state.posts = action.payload;
    },
    setComments: (state, action: PayloadAction<IComment[]>) => {
      state.comments = action.payload;
    },
    setProducts: (state, action: PayloadAction<IProduct[]>) => {
      state.products = action.payload;
    },
    addPost: (state, action: PayloadAction<IPost>) => {
      state.posts.push(action.payload);
    },
    updatePost: (state, action: PayloadAction<IPost>) => {
      const index = state.posts.findIndex((p) => p.id === action.payload.id);
      if (index !== -1) {
        state.posts[index] = action.payload;
      }
    },
    deletePost: (state, action: PayloadAction<number>) => {
      state.posts = state.posts.filter((p) => p.id !== action.payload);
    },
  },
  extraReducers: (builder) => {
    // Ссылаемся на action из authSlice
    builder.addCase(logout, (state) => {
      state.posts = [];
      state.comments = [];
      state.products = [];
    });
  },
});

export const { setPosts, setComments, setProducts, addPost, updatePost, deletePost } =
  dataSlice.actions;
export default dataSlice.reducer;