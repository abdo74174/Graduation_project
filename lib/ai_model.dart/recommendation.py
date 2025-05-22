import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# 1. قراءة بيانات المنتجات من SQL Server
def load_data(connection_string):
    try:
        engine = create_engine(connection_string)
        query = "SELECT ProductId, Description FROM Products"
        df = pd.read_sql(query, engine)
        if df.empty:
            raise ValueError("No data found in the Products table")
        return df
    except Exception as e:
        raise Exception(f"Database error: {str(e)}")

# 2. تنظيف النصوص
def clean_text(text):
    if pd.isna(text) or not text:
        return ""
    text = text.lower().strip()
    text = ''.join(e for e in text if e.isalnum() or e.isspace())
    return text

# 3. بناء نموذج التوصية
def build_recommendation_model(df):
    df['clean_description'] = df['Description'].apply(clean_text)
    vectorizer = TfidfVectorizer(max_features=5000, stop_words='english')
    tfidf_matrix = vectorizer.fit_transform(df['clean_description'])
    cosine_similarity_matrix = cosine_similarity(tfidf_matrix)
    return cosine_similarity_matrix, df

# 4. دالة إرجاع المنتجات المشابهة
def get_similar_products(product_id, cosine_similarity_matrix, df, top_n=3):
    idx = df.index[df['ProductId'] == product_id].tolist()
    if not idx:
        raise ValueError(f"Product ID {product_id} not found")
    idx = idx[0]
    similarities = cosine_similarity_matrix[idx]
    similar_indices = np.argsort(similarities)[::-1][1:top_n+1]
    similar_products = df.iloc[similar_indices][['ProductId', 'Description']].to_dict('records')
    return similar_products

# مثال على الاستخدام
if __name__ == "__main__":
    try:
        # Connection String (SQLAlchemy format)
        connection_string = "mssql+pyodbc://sa:sa123456@DESKTOP-6F8T0T6/MedBridge?driver=ODBC+Driver+17+for+SQL+Server"
        df = load_data(connection_string)
        cosine_sim_matrix, df = build_recommendation_model(df)
        product_id = 44  # Testing with ProductId = 44
        recommendations = get_similar_products(product_id, cosine_sim_matrix, df, top_n=3)
        print("المنتجات المشابهة:")
        for product in recommendations:
            print(f"Product ID: {product['ProductId']}, Description: {product['Description']}")
    except Exception as e:
        print(f"Error: {str(e)}")