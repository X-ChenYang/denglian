# app.py
from flask import Flask, render_template
import plotly.graph_objs as go
import plotly.utils
import json
import random
import pymysql

app = Flask(__name__)




def get_data():
    try:
        # 连接 MySQL 数据库
        connection = pymysql.connect(
            host='127.0.0.1',  # 数据库地址
            port= 3306,
            user='stock_app',  # 用户名
            password='123456',  # 密码
            database='stock_data',  # 数据库名
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor  # 返回字典格式
        )

        with connection:
            with connection.cursor() as cursor:
                # 查询最近10条记录，按时间升序排列（确保图表从左到右是时间顺序）
                sql = """
                    SELECT `成交额` as value
                    FROM StockPrice
                    ORDER BY `插入时间` DESC
                    LIMIT 10
                """
                cursor.execute(sql)
                rows = cursor.fetchall()

                # 因为是倒序查的，需要反转以保证时间从早到晚
                rows = list(reversed(rows))

                if not rows:
                    raise ValueError("No data found in table.")

                # times = [row['timestamp'] for row in rows]
                times = list(range(10))
                values = [float(row['value']) for row in rows]
                print(values)
                formatted = [f"{v / 10000:.2f}万" for v in values]
                print(formatted)
                # 转换为“万元”，保留两位小数（可选）
                values_in_wan = [round(v / 10000, 2) for v in values]
                print(values_in_wan)
                return times, values_in_wan

    except Exception as e:
        print(f"Database error: {e}")
        # 出错时回退到模拟数据，避免页面崩溃
        import random
        values = [random.uniform(80, 120) for _ in range(10)]
        times = list(range(10))
        return times, values


# 模拟数据（实际可替换为数据库查询或 API 调用）
# def get_data():
#     values = [random.uniform(80, 120) for _ in range(10)]
#     times = list(range(10))
#     return times, values


@app.route('/')
def index():
    x, y = get_data()

    # 预警判断（例如：超过 110 视为异常）
    # alert = any(v > 110 for v in y)
    alert = True
    # 创建 Plotly 图表
    fig = go.Figure()
    fig.add_trace(go.Scatter(x=x, y=y, mode='lines+markers', name='监测值'))
    fig.add_hline(y=110, line_dash="dash", line_color="red", annotation_text="预警阈值")

    graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
    return render_template('index.html', graphJSON=graphJSON, alert=alert)


if __name__ == '__main__':
    app.run(debug=True)