from flask import Flask, request, jsonify
from recommendation import load_data, build_recommendation_model, get_similar_products

app = Flask(__name__)

connection_string = "mssql+pyodbc://sa:sa123456@DESKTOP-6F8T0T6/MedBridge?driver=ODBC+Driver+17+for+SQL+Server"
df = load_data(connection_string)
cosine_sim_matrix, df = build_recommendation_model(df)

@app.route("/recommend", methods=["GET"])
def recommend():
    try:
        product_id = int(request.args.get("product_id"))
        top_n = int(request.args.get("top_n", 3))
        results = get_similar_products(product_id, cosine_sim_matrix, df, top_n)
        return jsonify({
            "status": "success",
            "product_id": product_id,
            "recommendations": results
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 400

if __name__ == "__main__":
    app.run(debug=True, host='0.0.2.2', port=5000)  # Match your ASP.NET Core base URL