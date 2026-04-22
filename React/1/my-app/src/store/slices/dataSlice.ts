import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { IPost } from '../../types/post';


interface IProduct {
  id: number;
  name: string;
  price: number;
  description: string;
}

interface DataState {
  posts: IPost[];
  products: IProduct[];
  comments: any[];
}

const initialState: DataState = {
  posts: [],
  products: [],
  comments: [],
};

const dataSlice = createSlice({
  name: 'data',
  initialState,
  reducers: {
    setPosts(state, action: PayloadAction<IPost[]>) {
      state.posts = action.payload;
    },
    addPost(state, action: PayloadAction<IPost>) {
      state.posts.push(action.payload);
    },
    updatePost(state, action: PayloadAction<IPost>) {
      const index = state.posts.findIndex(post => post.id === action.payload.id);
      if (index !== -1) {
        state.posts[index] = action.payload;
      }
    },
    deletePost(state, action: PayloadAction<number>) {
      state.posts = state.posts.filter(post => post.id !== action.payload);
    },
    setProducts(state, action: PayloadAction<IProduct[]>) {
      state.products = action.payload;
    },
    addProduct(state, action: PayloadAction<IProduct>) {
      state.products.push(action.payload);
    },
    updateProduct(state, action: PayloadAction<IProduct>) {
      const index = state.products.findIndex(product => product.id === action.payload.id);
      if (index !== -1) {
        state.products[index] = action.payload;
      }
    },
    deleteProduct(state, action: PayloadAction<number>) {
      state.products = state.products.filter(product => product.id !== action.payload);
    },
    setComments(state, action: PayloadAction<any[]>) {
      state.comments = action.payload;
    },
  },
});

export const {
  addPost,
  deletePost,
  setPosts,
  updatePost,
  setProducts,
  addProduct,
  updateProduct,
  deleteProduct,
  setComments,
} = dataSlice.actions;

export default dataSlice.reducer;